#include "Precompiled.h"
#include "../include/ConfigReader.h"

ConfigReader::ConfigReader()
{
	m_pElem = NULL;
}

bool ConfigReader::Open( const char* pFile )
{
	unsigned long size = 0;

	if (!m_doc.LoadFile(pFile))
		return false;

	m_pElem = m_doc.RootElement();
	if (!m_pElem)
		return false;
	m_pElem = m_pElem->FirstChildElement();
	m_pAttr = m_pElem->FirstAttribute();

	return true;
}

bool ConfigReader::NextElem()
{
	if (!m_pElem)
		return false;
	m_pElem = m_pElem->NextSiblingElement();
	if (!m_pElem)
		return false;
	m_pAttr = m_pElem->FirstAttribute();
	return true;
}

const char* ConfigReader::ElemText()
{
	if (!m_pElem)
		return NULL;
	return m_pElem->GetText();
}

bool ConfigReader::IsElemValid()
{
	return m_pElem;
}

bool ConfigReader::NextAttr()
{
	if (!m_pAttr)
		return false;
	m_pAttr = m_pAttr->Next();
	return m_pAttr;
}

bool ConfigReader::IsAttrValid()
{
	return m_pAttr;
}

const char* ConfigReader::AttrName()
{
	if (!m_pAttr)
		return NULL;
	return m_pAttr->Name();
}

const char* ConfigReader::AttrText()
{
	if (!m_pAttr)
		return NULL;
	return m_pAttr->Value();
}

const char* ConfigReader::AttrTextByName( const char* pName )
{
	return m_pElem->Attribute(pName);
}

int ConfigReader::AttrIntByName( const char* pName )
{
	int val;
	int  nRet = m_pElem->QueryIntAttribute(pName, &val);
	assert(!nRet);
	return val;
}

double ConfigReader::AttrDoubleByName( const char* pName )
{
	double val;
	int nRet = m_pElem->QueryDoubleAttribute(pName, &val);
	assert(!nRet);
	return val;
}

void ConfigReader::Close()
{
}
