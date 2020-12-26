#include<bits/stdc++.h>
//#include "1505037_symboltable.h"

using namespace std;


struct SymbolInfoFunc {
	string retType;
	int NumberOfParam;
	vector<string> paramList;
	vector<string> parameters;
};

    // SymbolInfo Class

class SymbolInfo {
    string name;
    string type;
    
    string varType;
    string idType;
    

public:
    struct SymbolInfoFunc *funcInfo;
    SymbolInfo *next;
    string code;
    SymbolInfo();
    SymbolInfo(string n);
    SymbolInfo(string n, string t);
    SymbolInfo(string n, string t, string vt);
    void setName(string n);
    void setType(string t);
    void setVarType(string vt);
    void setIdType(string it);
    string getName();
    string getType();
    string getVarType();
    string getIdType();
    SymbolInfoFunc *getFuncInfo();
};

SymbolInfo::SymbolInfo() {
	next = 0;
	funcInfo = 0;
	code = "";
}

SymbolInfo::SymbolInfo(string n) {
	this->name = n;
	next = 0;
	funcInfo = 0;
	code = "";
}

SymbolInfo::SymbolInfo(string n, string t) {
	this->name = n;
	this->type = t;
	next = 0;
	funcInfo = 0;
	code = "";
}

SymbolInfo::SymbolInfo(string n, string t, string vt) {
	this->name = n;
	this->type = t;
	this->varType = vt;
	next = 0;
	funcInfo = 0;
	code = "";
}



void SymbolInfo::setName(string n) {
    this->name = n;
}

void SymbolInfo::setType(string t) {
    this->type = t;
}

void SymbolInfo::setVarType(string vt) {
	this->varType = vt;
}

void SymbolInfo::setIdType(string it) {
	this->idType = it;
}

string SymbolInfo::getName() {
    return this->name;
}

string SymbolInfo::getType() {
    return this->type;
}

string SymbolInfo::getVarType() {
	return this->varType;
}

string SymbolInfo::getIdType() {
	return this->idType;
}

SymbolInfoFunc* SymbolInfo::getFuncInfo() {
	return this->funcInfo;
}

    //ScopeTable Class

class ScopeTable {
public:
    SymbolInfo **head;
    ScopeTable *parentScope;
    static int currentId;
    int uniqueId;
    int BucketSize;
    ScopeTable(int n);                  //parameter n for bucket number
    ~ScopeTable();
    unsigned int HashFunc(string word);
    bool Insert(SymbolInfo *symbol);
    SymbolInfo *LookUp(string symbol);
    bool Delete(string symbol);
    void Print(FILE *& output);
};

ScopeTable::ScopeTable(int n) {
    head = new SymbolInfo*[n];          //allocate n buckets for hash table
    parentScope = 0;
    BucketSize = n;
    uniqueId = currentId;
    for (int i = 0; i < n; i++) {
        head[i] = 0;
    }
}

ScopeTable::~ScopeTable() {
    delete head;
    //delete parentScope;
}

bool ScopeTable::Insert(SymbolInfo *symbol) {
    unsigned int hashIndex = HashFunc(symbol->getName());
    bool check = true;
    if(head[hashIndex] == 0) {
        head[hashIndex] = symbol;
        return true;
    }
    else if(head[hashIndex]->getName().compare(symbol->getName()) == 0) return false;

    SymbolInfo *ptemp = head[hashIndex];
    SymbolInfo *temp = head[hashIndex]->next;
    while(temp != 0) {
        if(temp->getName().compare(symbol->getName()) == 0) check = false;
        ptemp = ptemp->next;
        temp = temp->next;
    }
    if(check) {
        ptemp->next = symbol;
    }
    return check;
}

SymbolInfo* ScopeTable::LookUp(string symbol) {
    unsigned int hashIndex = HashFunc(symbol);

    SymbolInfo *temp = head[hashIndex];

    while(temp != 0) {
        if(temp->getName().compare(symbol) == 0) return temp;
        temp = temp->next;
    }
    return 0;
}

bool ScopeTable::Delete(string symbol) {
    unsigned int hashIndex = HashFunc(symbol);

    if(head[hashIndex] == 0) return false;
    else if(head[hashIndex]->getName().compare(symbol) == 0) {
        SymbolInfo *temp = head[hashIndex];
        head[hashIndex] = head[hashIndex]->next;
        delete temp;
        return true;
    }

    SymbolInfo *ptemp = head[hashIndex];
    SymbolInfo *temp = head[hashIndex]->next;

    while(temp != 0) {
        if(temp->getName().compare(symbol) == 0) {
            ptemp->next = temp->next;
            delete temp;
            return true;
        }
        ptemp = ptemp->next;
        temp = temp->next;
    }
    return false;
}

/*void ScopeTable::Print(ofstream &output) {
    printf("\nScopeTable # %d\n", uniqueId);
    output << endl << "ScopeTable# " << uniqueId << endl;

    for(int i = 0; i < BucketSize; i++) {
        printf("%d --> ", i);

        output << i << " --> ";
        SymbolInfo *temp = head[i];
        while(temp != 0) {
            cout << "< " << temp->getName() << " : " << temp->getType() << " >";
            cout << "\t";

            output << "< " << temp->getName() << " : " << temp->getType() << " >";
            output << "\t";
            temp = temp->next;
        }
        printf("\n");
        output << endl;
    }
    printf("\n");
    output << endl;
}*/

void ScopeTable::Print(FILE *& output) {
    fprintf(output, "\nScopeTable # %d\n", uniqueId);

    for(int i = 0; i < BucketSize; i++) {
        SymbolInfo *temp = head[i];

	if(temp != 0) {
	    fprintf(output, "%d --> ", i);
	}
        while(temp != 0) {
	    fprintf(output, "< %s : %s : %s>\t", temp->getName().c_str(), temp->getType().c_str(), temp->getVarType().c_str());
            temp = temp->next;
        }
        if(head[i]) fprintf(output,"\n");
    }
    fprintf(output, "\n\n");
}

unsigned int ScopeTable::HashFunc(string word) {
    unsigned int b = 378551;
    unsigned int a = 63689;
    unsigned int hash = 0;
    int LengthOfWord = word.length();

    for (int i = 0; i < LengthOfWord; ++i) {
        hash = hash*a + word[i];
        a = a*b;
    }

    return (hash%100000007)%BucketSize;
}

int ScopeTable::currentId = 0;  //Initialize static variable

    //SymbolTable Class

class SymbolTable {
public:
    int BucketSize;
    ScopeTable *current;
    ScopeTable *currentLookUp;

    static int currentScopeNum;
    pair<unsigned int, int> getLocation(string word);

    SymbolTable(int n);
    void EnterScope();
    void ExitScope();
    bool Insert(SymbolInfo *symbol);
    bool Remove(string symbol);
    SymbolInfo *LookUp(string symbol);
    SymbolInfo *LookUpCurrent(string symbol);
    void PrintCurrent(FILE *& output);
    void PrintAll(FILE *& output);
};

int SymbolTable::currentScopeNum = 0;

pair<unsigned int, int> SymbolTable::getLocation(string symbol) {
    pair<unsigned int, int> location;
    unsigned int hashIndex = currentLookUp->HashFunc(symbol);

    SymbolInfo *temp = currentLookUp->head[hashIndex];
    int i = 0;

    while(temp != 0) {
        if(temp->getName().compare(symbol) == 0) break;
        i++;
        temp = temp->next;
    }
    location = make_pair(hashIndex, i);
    currentScopeNum = currentLookUp->uniqueId;
    currentLookUp = current;
    return location;
}

SymbolTable::SymbolTable(int n) {
    BucketSize = n;
    ScopeTable::currentId++;
    ScopeTable *S = new ScopeTable(BucketSize);
    S->parentScope = 0;
    current = S;
}

void SymbolTable::EnterScope() {
    ScopeTable::currentId++;
    ScopeTable *S = new ScopeTable(BucketSize);
    S->parentScope = current;
    current = S;
}

void SymbolTable::ExitScope(){
    ScopeTable *temp = current;
    current = current->parentScope;
    delete temp;
    //ScopeTable::currentId--;
}

bool SymbolTable::Insert(SymbolInfo *symbol) {
    return current->Insert(symbol);
}

bool SymbolTable::Remove(string symbol) {
    ScopeTable *temp = current;
    while(temp != 0) {
        return temp->Delete(symbol);
        temp = temp->parentScope;
    }
    return false;
}

SymbolInfo* SymbolTable::LookUp(string symbol) {
    ScopeTable *temp = current;
    SymbolInfo *check = 0;
    while(temp != 0) {
        currentLookUp = temp;
        check =  temp->LookUp(symbol);
        if(check != 0) break;
        temp = temp->parentScope;
    }
    return check;
}

SymbolInfo* SymbolTable::LookUpCurrent(string symbol) {
	return current->LookUp(symbol);
}

void SymbolTable::PrintCurrent(FILE *& output) {
    current->Print(output);
}

void SymbolTable::PrintAll(FILE *& output) {
    ScopeTable *temp = current;
    while(temp != 0) {
        temp->Print(output);
        temp = temp->parentScope;
    }
}
