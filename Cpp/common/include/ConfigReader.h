#pragma once
#include "../../external/tinyxml/src/tinyxml.h"

class ConfigReader
{
public:
	ConfigReader();
	~ConfigReader() {}

	bool Open(const char* pFile);
	bool NextElem();
	bool IsElemValid();

	bool NextAttr();
	bool IsAttrValid();

	const char* ElemText();

	const char* AttrName();
	const char* AttrText();

	const char* AttrTextByName(const char* pName);
	int AttrIntByName(const char* pName);
	double AttrDoubleByName(const char* pName);

	void Close();
private:
	TiXmlDocument m_doc;
	TiXmlElement *m_pElem;
	const TiXmlAttribute *m_pAttr;
};

