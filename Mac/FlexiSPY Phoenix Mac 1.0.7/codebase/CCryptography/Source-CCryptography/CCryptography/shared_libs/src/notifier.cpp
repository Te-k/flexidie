
#include <notifier.h>


void cBaseNotifier::setListener ( cBaseListener* oNewListener )
{
	// for set we will allow 1 listener
	if ( !m_vecView.empty() )
		m_vecView.clear();

	m_vecView.push_back ( oNewListener );
}

void cBaseNotifier::addListener ( cBaseListener* oNewListener )
{
	m_vecView.push_back ( oNewListener );
}

void cBaseNotifier::notifyListeners ( cBaseDescriptor* oDescriptor )
{
	// Notify all the item
	std::vector<cBaseListener*>::iterator it = m_vecView.begin();
	for (; it != m_vecView.end(); it ++ )
		(*it)->onNotify( oDescriptor );
}
