/****************************************************************************
**
** Project   : QWBFS Manager
** FileName  : ThemedSvgIconPlugin.cpp
** License   : GPL2
** Home Page : https://github.com/letzzar/qwbfsmanager
**
** Static icon engine plugin: QIcon( ":/icons/foo.tsvg" ) creates a
** ThemedSvgIconEngine, including from Qt Designer .ui files.
**
****************************************************************************/
#include "ThemedSvgIconEngine.h"

#include <QIconEnginePlugin>

class ThemedSvgIconPlugin : public QIconEnginePlugin
{
    Q_OBJECT
    Q_PLUGIN_METADATA( IID QIconEngineFactoryInterface_iid FILE "themedsvgicon.json" )

public:
    QIconEngine* create( const QString& fileName = QString() ) override
    {
        return new ThemedSvgIconEngine( fileName );
    }
};

#include "ThemedSvgIconPlugin.moc"
