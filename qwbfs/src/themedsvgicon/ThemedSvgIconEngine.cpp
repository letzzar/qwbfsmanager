/****************************************************************************
**
** Project   : QWBFS Manager
** FileName  : ThemedSvgIconEngine.cpp
** License   : GPL2
** Home Page : https://github.com/letzzar/qwbfsmanager
**
****************************************************************************/
#include "ThemedSvgIconEngine.h"

#include <QFile>
#include <QGuiApplication>
#include <QPainter>
#include <QPalette>
#include <QPixmap>
#include <QPixmapCache>
#include <QSvgRenderer>

ThemedSvgIconEngine::ThemedSvgIconEngine( const QString& fileName )
    : QIconEngine()
{
    if ( !fileName.isEmpty() ) {
        addFile( fileName, QSize(), QIcon::Normal, QIcon::Off );
    }
}

QColor ThemedSvgIconEngine::colorForMode( QIcon::Mode mode )
{
    const QPalette palette = QGuiApplication::palette();

    switch ( mode ) {
        case QIcon::Disabled:
            return palette.color( QPalette::Disabled, QPalette::WindowText );
        case QIcon::Selected:
            return palette.color( QPalette::Active, QPalette::HighlightedText );
        case QIcon::Normal:
        case QIcon::Active:
            break;
    }

    return palette.color( QPalette::Active, QPalette::WindowText );
}

void ThemedSvgIconEngine::paint( QPainter* painter, const QRect& rect, QIcon::Mode mode, QIcon::State state )
{
    const qreal scale = painter->device() ? painter->device()->devicePixelRatioF() : qApp->devicePixelRatio();
    painter->drawPixmap( rect, scaledPixmap( rect.size(), mode, state, scale ) );
}

QPixmap ThemedSvgIconEngine::pixmap( const QSize& size, QIcon::Mode mode, QIcon::State state )
{
    return scaledPixmap( size, mode, state, 1.0 );
}

QPixmap ThemedSvgIconEngine::scaledPixmap( const QSize& size, QIcon::Mode mode, QIcon::State state, qreal scale )
{
    Q_UNUSED( state );

    if ( mSvg.isEmpty() || size.isEmpty() ) {
        return QPixmap();
    }

    const QColor color = colorForMode( mode );
    const QSize pixelSize = size *scale;
    const QString cacheKey = QStringLiteral( "tsvg:%1:%2x%3:%4" )
        .arg( mFileName ).arg( pixelSize.width() ).arg( pixelSize.height() ).arg( color.rgba(), 0, 16 );
    QPixmap pixmap;

    if ( !QPixmapCache::find( cacheKey, &pixmap ) ) {
        QByteArray svg = mSvg;
        svg.replace( "currentColor", color.name( QColor::HexRgb ).toLatin1() );

        QSvgRenderer renderer( svg );
        pixmap = QPixmap( pixelSize );
        pixmap.fill( Qt::transparent );

        QPainter painter( &pixmap );
        painter.setRenderHint( QPainter::Antialiasing );
        // keep the aspect ratio of the svg view box
        QSizeF target = renderer.viewBoxF().size();
        target.scale( pixelSize, Qt::KeepAspectRatio );
        const QRectF bounds( QPointF( ( pixelSize.width() -target.width() ) /2.0, ( pixelSize.height() -target.height() ) /2.0 ), target );
        renderer.render( &painter, bounds );

        if ( color.alphaF() < 1.0 ) {
            painter.setCompositionMode( QPainter::CompositionMode_DestinationIn );
            painter.fillRect( pixmap.rect(), QColor( 0, 0, 0, color.alpha() ) );
        }

        painter.end();
        QPixmapCache::insert( cacheKey, pixmap );
    }

    pixmap.setDevicePixelRatio( scale );
    return pixmap;
}

QSize ThemedSvgIconEngine::actualSize( const QSize& size, QIcon::Mode mode, QIcon::State state )
{
    Q_UNUSED( mode );
    Q_UNUSED( state );
    return size;
}

void ThemedSvgIconEngine::addFile( const QString& fileName, const QSize& size, QIcon::Mode mode, QIcon::State state )
{
    Q_UNUSED( size );
    Q_UNUSED( mode );
    Q_UNUSED( state );

    QFile file( fileName );

    if ( file.open( QIODevice::ReadOnly ) ) {
        mSvg = file.readAll();
        mFileName = fileName;
    }
    else {
        qWarning( "%s: Can't open %s", Q_FUNC_INFO, qPrintable( fileName ) );
    }
}

QIconEngine* ThemedSvgIconEngine::clone() const
{
    return new ThemedSvgIconEngine( *this );
}

QString ThemedSvgIconEngine::key() const
{
    return QStringLiteral( "ThemedSvgIconEngine" );
}

bool ThemedSvgIconEngine::isNull()
{
    return mSvg.isEmpty();
}
