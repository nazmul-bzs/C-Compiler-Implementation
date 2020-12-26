#include<bits/stdc++.h>

using namespace std;

    // SymbolInfo Class

class SymbolInfo {
    string name;
    string type;

public:
    SymbolInfo *next;
    void setName(string n);
    void setType(string t);
    string getName();
    string getType();
};

void SymbolInfo::setName(string n) {
    this->name = n;
}

void SymbolInfo::setType(string t) {
    this->type = t;
}

string SymbolInfo::getName() {
    return name;
}

string SymbolInfo::getType() {
    return type;
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
    void Print(ofstream &output);
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

void ScopeTable::Print(ofstream &output) {
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
    void PrintCurrent(ofstream &output);
    void PrintAll(ofstream &output);
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
    ScopeTable::currentId--;
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

void SymbolTable::PrintCurrent(ofstream &output) {
    current->Print(output);
}

void SymbolTable::PrintAll(ofstream &output) {
    ScopeTable *temp = current;
    while(temp != 0) {
        temp->Print(output);
        temp = temp->parentScope;
    }
}

int main() {
    stringstream result;
    int n;
    string str;
    ifstream input;
    ofstream output;
    input.open("input.txt");
    output.open("output.txt");
    getline(input, str);
    n = atoi(str.c_str());
    SymbolTable *s;
    s = new SymbolTable(n);
    while(!input.eof()) {
        getline(input, str);
        result.str("");
        result << "\n" << str << "\n";
        output << result.str();
        stringstream ss(str);
        string buf;
        while(ss >> buf) {
            if(buf.compare("I") == 0) {
                SymbolInfo *newNode = new SymbolInfo();
                ss >> buf;
                newNode->setName(buf);
                ss >> buf;
                newNode->setType(buf);
                newNode->next = 0;
                if((s->LookUp(newNode->getName())) != 0) {
                    cout << "< " << newNode->getName() << " : " << newNode->getType() << " >\t";
                    printf("Already inserted in ScopeTable# %d\n", ScopeTable::currentId);

                    output << "< " << newNode->getName() << " : " << newNode->getType() << " >\t";
                    output << "Already inserted in ScopeTable# " << ScopeTable::currentId << endl;
                }
                else {
                    s->Insert(newNode);
                    pair<unsigned int, int> p = s->getLocation(newNode->getName());
                    printf("Inserted in ScopeTable# %d at position %d, %d\n", ScopeTable::currentId, p.first, p.second);

                    output << "Inserted in ScopeTable# " << ScopeTable::currentId << " at position " << p.first << ", " << p.second << endl;
                }
            }
            else if(buf.compare("E") == 0) {
                printf("ScopeTable with id %d removed\n", ScopeTable::currentId);

                output << "ScopeTable with id " << ScopeTable::currentId << " removed" << endl;
                s->ExitScope();
            }
            else if(buf.compare("L") == 0) {
                ss >> buf;
                if(s->LookUp(buf) == 0) {
                    printf("Not found\n");
                    output << "Not found" << endl;
                }
                else {
                    pair<unsigned int, int> p = s->getLocation(buf);
                    printf("Found in ScopeTable# %d at position %d, %d\n", SymbolTable::currentScopeNum, p.first, p.second);

                    output << "Found in ScopeTable# " << SymbolTable::currentScopeNum << " at position " << p.first << ", " << p.second << endl;
                    SymbolTable::currentScopeNum = ScopeTable::currentId;
                }
            }
            else if(buf.compare("P") == 0) {
                ss >> buf;
                if(buf.compare("A") == 0) s->PrintAll(output);
                else if(buf.compare("C") == 0) s->PrintCurrent(output);
            }
            else if(buf.compare("D") == 0) {
                ss >> buf;
                if(s->LookUp(buf) == 0) {
                    printf("Not found\n");
                    cout << buf << " not found" << endl;

                    output << "Not found" << endl;
                    output << buf << " not found" << endl;
                }
                else {

                    pair<unsigned int, int> p = s->getLocation(buf);
                    printf("Found in ScopeTable# %d at position %d, %d\n", ScopeTable::currentId, p.first, p.second);

                    output << "Found in ScopeTable# " << ScopeTable::currentId << " at position " << p.first << ", " << p.second << endl;
                    s->Remove(buf);
                    printf("Deleted entry at %d, %d from current ScopeTable\n", p.first, p.second);

                    output << "Deleted entry at " << p.first << ", " << p.second << " from current ScopeTable" << endl;
                }
            }
            else if(buf.compare("S") == 0) {
                s->EnterScope();
                printf("New ScopeTable with id %d created\n", ScopeTable::currentId);

                output << "New ScopeTable with id " << ScopeTable::currentId << " created" << endl;
            }
        }

    }
    input.close();
    output.close();
    return 0;
}
