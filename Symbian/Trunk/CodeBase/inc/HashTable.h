#ifndef __HASH_TABLE_H
#define __HASH_TABLE_H
#include <e32std.h>
#include <stdlib.h>
#include <string.h>
#include <e32base.h>


template <class T>
class CHashTable
{
protected:

	struct HashNode
	{
		TInt Key;
		T* Value;
		HashNode* Next;
	};


public:
	CHashTable(const TInt size)
	{
		//Nodes = new (ELeave) HashNode*[size];
		Nodes = (HashNode**)calloc(sizeof(HashNode*),size);

		//ValueList = new (ELeave) T[size];
		ValueList = new (ELeave) CArrayFixFlat<T*>(size);

		memset(Nodes,0,size*sizeof(HashNode*));

		this->size = size;
		count = 0;
	};

	~CHashTable()
	{

		Clear();
		//delete[] Nodes;
		free(Nodes);


		delete ValueList;
	};


	void Put(TInt aKey, T* aValue)
	{
		TInt hashcode = 0;
		hashcode = aKey - (aKey/size)*size;

		ValueList->AppendL(aValue);


		if(Nodes[hashcode]==NULL){
			HashNode* n = new HashNode();
			n->Key = aKey;
			n->Value = aValue;
			n->Next = NULL;
			Nodes[hashcode] = n;
			++count;
		}
		else{
			HashNode* node = Nodes[hashcode];
			if(node->Key==aKey){
				if(node->Value!=NULL)
				{
				    //delete node->Value;
					for(TInt i=ValueList->Count()-1;i>=0;--i)
	    			    if(ValueList->At(i)==node->Value)
						{
							delete ValueList->At(i);
						    ValueList->Delete(i);
							break;
						}
				}
				node->Value = aValue;
				return;
			}
			while(node->Next!=NULL){
				node = node->Next;
				if(node->Key==aKey){
					if(node->Value!=NULL)
					{
						//delete node->Value;
						for(TInt i=ValueList->Count()-1;i>=0;--i)
							if(ValueList->At(i)==node->Value)
							{
								delete ValueList->At(i);
								ValueList->Delete(i);
								break;
							}
					}
					node->Value = aValue;
					return;
				}
			}
			HashNode* n = new HashNode();
			n->Key = aKey;
			n->Value = aValue;
			n->Next = NULL;
			node->Next = n;
			++count;
		}
	};

	TBool Get(TInt aKey, T** aRetValue)
	{
		TInt hashcode = 0;
		hashcode = aKey - (aKey/size)*size;

		if(Nodes[hashcode]==NULL)
			return EFalse;
		else{
			HashNode* node = Nodes[hashcode];
			if(node->Key==aKey){
				*aRetValue = node->Value;
				return ETrue;
			}

			while(node->Next!=NULL){
				node = node->Next;
				if(node->Key==aKey){
					*aRetValue = node->Value;
					return ETrue;
				}
			}

			return EFalse;
		}


	};
	
	
	TBool Remove(TInt aKey)
	{
		TInt hashcode = 0;
		hashcode = aKey - (aKey/size)*size;
		if(Nodes[hashcode]!=NULL){
			HashNode* node = Nodes[hashcode];

			if(node->Key==aKey){
				HashNode* next = NULL;
				if(node->Value!=NULL)
				{
					//delete node->Value;
					for(TInt i=ValueList->Count()-1;i>=0;--i)
						if(ValueList->At(i)==node->Value)
						{
							delete ValueList->At(i);
							ValueList->Delete(i);
							break;
						}
				}
				next = node->Next;
				delete node;
				Nodes[hashcode] = next;

				count--;
				return ETrue;
			}

			HashNode* root = NULL;

			while(node->Next!=NULL){
				root = node;
				node = node->Next;
				if(node->Key==aKey){
					HashNode* next = NULL;
					if(node->Value!=NULL)
					{
						//delete node->Value;
						for(TInt i=ValueList->Count()-1;i>=0;--i)
							if(ValueList->At(i)==node->Value)
							{
								delete ValueList->At(i);
								ValueList->Delete(i);
								break;
							}
					}
					next = node->Next;
					delete node;
					root->Next = next;

					count--;
					return ETrue;
				}
			}


		}

		return EFalse;
	};

	TInt Count()
	{
		return count;
	};

	void Clear()
	{
		TInt left = count;
		for(TInt i=0;i<size;++i){
			if(left<=0)
			    break;

			if(Nodes[i]!=NULL){
				DeleteNode(Nodes[i]);
				Nodes[i] = NULL;
				--left;
			}
		}
		ValueList->Reset();
		

		count = 0;
	};

public:
	CArrayFixFlat<T*>* ValueList;

protected:
	HashNode** Nodes;
	TInt size;
	TInt count;


	void DeleteNode(HashNode* node)
	{
		if(node==NULL)
			return;

		if(node->Next!=NULL)
			DeleteNode(node->Next);
		delete node->Value;
		delete node;
	}





};


#endif
