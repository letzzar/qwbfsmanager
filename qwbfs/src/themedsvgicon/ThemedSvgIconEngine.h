/****************************************************************************
**
** Project   : QWBFS Manager
** FileName  : ThemedSvgIconEngine.h
** License   : GPL2
** Home Page : https://github.com/letzzar/qwbfsmanager
**
** Icon engine for monochrome SVG icons (*.tsvg files): every "currentColor"
** in the SVG is replaced at paint time by the palette color matching the
** icon mode, so icons follow the light/dark system theme automatically.
**
****************************************************************************/
#ifndef THEMEDSVGICONENGINE_H
#define THEMEDSVGICONENGINE_H

#include <QIconEngine>
#include <QByteArray>

class ThemedSvgIconEngine : public QIconEngine
{
public:
    ThemedSvgIconEngine( const QString& fileName = QString() );

    void paint( QPainter* painter, const QRect& rect, QIcon::Mode mode, QIcon::State state ) override;
    QPixmap pixmap( const QSize& size, QIcon::Mode mode, QIcon::State state ) override;
    QPixmap scaledPixmap( const QSize& size, QIcon::Mode mode, QIcon::State state, qreal scale ) override;
    QSize actualSize( const QSize& size, QIcon::Mode mode, QIcon::State state ) override;
    void addFile( const QString& fileName, const QSize& size, QIcon::Mode mode, QIcon::State state ) override;
    QIconEngine* clone() const override;
    QString key() const override;
    bool isNull() override;

    static QColor colorForMode( QIcon::Mode mode );

protected:
    QByteArray mSvg;
    QString mFileName;
};

#endif // THEMEDSVGICONENGINE_H
