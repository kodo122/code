#include "Precompiled.h"
#include "../include/Random.h"

int Rand( int min, int max )
{
	return rand() % (max - min + 1) + min;
}

void SRand( uint32 seed )
{
	srand(seed);
}
