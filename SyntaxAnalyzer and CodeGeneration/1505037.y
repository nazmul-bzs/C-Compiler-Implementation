%{
	#include<bits/stdc++.h>
	#include "1505037_symboltable.h"
	//#include "1505037_symbolinfo.h"
	//#define YYSTYPE SymbolInfo*
	#define SIZE_OF_BUCKET 100

	using namespace std;

	int yyparse(void);
	int yylex(void);
	extern FILE *yyin;
	extern int lineCount;

	SymbolTable *table;
	FILE *fp, *fp2, *fp3;
	vector<SymbolInfo*> params;
	vector<SymbolInfo*> param;
	vector<SymbolInfo*> vars;
	
	int noOfParams = 0;
	vector<string> paramsType;
	
	int noOfArgs = 0;
	vector<string> argsType;
	
	vector<SymbolInfo*> argsList;
	
	int totalErrors = 0;


	void yyerror(char *s) {
		//write your code
		fprintf(fp3, "Error at Line %d : %s\n\n", lineCount, s);
		totalErrors++;
	}
	
	
	
	int labelCount=0;
	int tempCount=0;


	string newLabel() {
		char *lb= new char[4];
		strcpy(lb,"L");
		char b[3];
		sprintf(b,"%d", labelCount);
		labelCount++;
		strcat(lb,b);
		string slb(lb);
		return slb;
	}

	string newTemp() {
		char *t= new char[4];
		strcpy(t,"t");
		char b[3];
		sprintf(b,"%d", tempCount);
		tempCount++;
		strcat(t,b);
		string st(t);
		return st;
	}
	
	string newVar(string var) {
		return (var + to_string(ScopeTable::currentId));
	}
	
	string printlnProc() {
		string s = "";
		s += "PRINTLN proc\n"
		s += "push ax\n";
		s += "push bx\n";
		s += "push cx\n";
		s += "push dx\n";
		s += "or ax, ax\n";
		s += "jge @END_IF1\n";
		s += "push ax\n";
		s += "mov dl, '-'\n";
		s += "mov ah, 2\n";
		s += "int 21h\n";
		s += "pop ax\n";
		s += "neg ax\n";
		s += "@END_IF1:\n";
		s += "xor cx, cx\n";
		s += "mov bx, 10D\n";
		s += "@REPEAT1:\n";
		s += "xor dx, dx\n";
		s += "div bx\n";
		s += "push dx\n";
		s += "inc cx\n";
		s += "or ax, ax\n";
		s += "jne @REPEAT1\n";
		s += "mov ah, 2\n";
		s += "@PRINT_LOOP:\n";
		s += "pop dx\n";
		s += "or dl, 30H\n";
		s += "int 21H\n";
		s += "LOOP @PRINT_LOOP\n";
		s += "pop dx\n";
		s += "pop cx\n";
		s += "pop bx\n";
		s += "pop ax\n";
		s += "PRINTLN endp\n";
		return s;
	}
	
	string varSec = "";
	
	
	
%}

%union{
	SymbolInfo* sval;
}

%token IF ELSE FOR WHILE DO BREAK INT CHAR FLOAT DOUBLE VOID RETURN SWITCH CASE DEFAULT CONTINUE PRINTLN
%token <sval>ADDOP <sval>MULOP <sval>INCOP <sval>RELOP <sval>ASSIGNOP 
%token <sval>LOGICOP <sval>BITOP NOT LPAREN RPAREN 
%token LCURL RCURL LTHIRD RTHIRD COMMA SEMICOLON
%token <sval>CONST_CHAR <sval>CONST_FLOAT <sval>ID <sval>CONST_INT 

%type <sval>start
%type <sval>program
%type <sval>unit
%type <sval>var_declaration
%type <sval>declaration_list
%type <sval>func_declaration
%type <sval>func_definition
%type <sval>type_specifier
%type <sval>parameter_list
%type <sval>compound_statement
%type <sval>statements
%type <sval>statement
%type <sval>expression_statement
%type <sval>expression
%type <sval>variable
%type <sval>logic_expression
%type <sval>rel_expression
%type <sval>simple_expression
%type <sval>term
%type <sval>unary_expression
%type <sval>factor
%type <sval>argument_list
%type <sval>arguments


%left '+' '-'
%left '*' '/'
%right '='

%nonassoc LOWER_THAN_ELSE
%nonassoc ELSE
%%

start : program					{	
									$$ = $1;
									table->PrintAll(fp2);
									fprintf(fp2, "Total Line no : %d\n\n", lineCount-1);
									fprintf(fp2, "Total Error : %d\n\n", totalErrors);
								}
	  ;
	  
	  

program : program unit			{ 	
									$$ = $1;
									$$->code += $2->code;
								} 

		| unit					{ 
									$$ = $1;
								}
		;
		
		
	
unit 	: var_declaration		{
									
								}
									  
     	| func_declaration		{
     								
								}
									  
     	| func_definition		{
     								$$ = $1;
								}
     	;
     	
     	
     
func_declaration 	: type_specifier ID LPAREN parameter_list RPAREN SEMICOLON	{ 
				
								if(table->LookUp($2->getName()) == 0) {
									$2->setVarType($1->getType());
									$2->setIdType("FUNC");
									table->Insert($2);
		  							SymbolInfo *temp = table->LookUp($2->getName());
		  							if(temp->funcInfo == 0) {
			  							temp->funcInfo = new SymbolInfoFunc();
	  									temp->funcInfo->retType = $1->getType();
	  									temp->funcInfo->NumberOfParam = noOfParams;
	  									for(int i = 0; i < paramsType.size(); i++) {
	  										temp->funcInfo->paramList.push_back(paramsType[i]);
										}
	  								}
	  							}
								else {
									fprintf(fp3, "Error at Line %d : Multiple definition of Identifier \"%s\"\n\n", lineCount, $2->getName());
									totalErrors++;
 								} 
								noOfParams = 0;
  							  	paramsType.clear();
  							  	params.clear();     //added after fixing bugs
  							  	param.clear();
 																					}

					| type_specifier ID LPAREN RPAREN SEMICOLON						{ 
					
								if(table->LookUp($2->getName()) == 0) {
									$2->setVarType($1->getType());
									$2->setIdType("FUNC");
	  								table->Insert($2);
	  							 	SymbolInfo *temp = table->LookUp($2->getName());
									if(temp->funcInfo == 0) {
									 	temp->funcInfo = new SymbolInfoFunc();
									  	temp->funcInfo->retType = $1->getType();
									  	temp->funcInfo->NumberOfParam = 0;
									}
								}
		  						else {
							  		fprintf(fp3, "Error at Line %d : Multiple definition of Identifier \"%s\"\n\n", lineCount, $2->getName());
							  		totalErrors++;
			  					} 
			  					noOfParams = 0;
			  					paramsType.clear();
																					}
 					
					;
					
					
		 
func_definition : type_specifier ID LPAREN parameter_list RPAREN { 
						
							if(table->LookUp($2->getName()) == 0) {
								$2->setVarType($1->getType());
								$2->setIdType("FUNC");
								table->Insert($2);
							}
							SymbolInfo *temp = table->LookUp($2->getName());
		  					if(temp->funcInfo == 0) {
		  						temp->funcInfo = new SymbolInfoFunc();
								temp->funcInfo->retType = $1->getType();
								temp->funcInfo->NumberOfParam = noOfParams;
								for(int i = 0; i < paramsType.size(); i++) {
									temp->funcInfo->paramList.push_back(paramsType[i]);
								}
		  					}
							else {
								if(temp->funcInfo->retType.compare($1->getType()) != 0) {
									fprintf(fp3, "Error at Line %d : Return type not mached\n\n", lineCount);
									totalErrors+;
								}																
								if(temp->funcInfo->NumberOfParam != noOfParams) {
									fprintf(fp3, "Error at Line %d : Parameter number not mached\n\n", lineCount);
									totalErrors++;
								}
 							} 
							noOfParams = 0;
		  					paramsType.clear();
		  											  				} 	compound_statement 	{ 
 													  					  
 							$$ = new SymbolInfo();
 							$$->code += $2->getName() + " proc\n";
 							
 							$$->code += "push ax\n";
 							$$->code += "push bx\n";
 							$$->code += "push cx\n";
 							$$->code += "push dx\n";
 							
 							$$->code += $7->code;
 							
 							$$->code += "pop dx\n";
 							$$->code += "pop cx\n";
 							$$->code += "pop bx\n";
 							$$->code += "pop ax\n";
 							
 							$$->code += "ret\n" + $2->getName() + " endp\n";
 							SymbolInfo *temp = table->LookUp($2->getName());
		  					if(temp->funcInfo != 0) {
		  						for(int i = 0; i < param.size(); i++) {
									temp->funcInfo->parameter.push_back(param[i]->getName() + to_string(ScopeTabel::currentId-1));
								}
		  					}
		  					param.clear();
 							
 																							}
 													  					  
				| type_specifier ID LPAREN RPAREN 	{ 
				
							if(table->LookUp($2->getName()) == 0) {
								$2->setVarType($1->getType());
								table->Insert($2);
							}
							SymbolInfo *temp = table->LookUp($2->getName());
		  					if(temp->funcInfo == 0) {
							 	temp->funcInfo = new SymbolInfoFunc();
							  	temp->funcInfo->retType = $1->getType();
							  	temp->funcInfo->NumberOfParam = 0;
						  	}
		  					else {
								if(temp->funcInfo->retType.compare($1->getType()) != 0) {
									fprintf(fp3, "Error at Line %d : Return type not mached\n\n", lineCount);
									totalErrors++;
								}													
								if(temp->funcInfo->NumberOfParam != noOfParams) {
									fprintf(fp3, "Error at Line %d : Parameter number not mached\n\n", lineCount);
									totalErrors++;
								}
							} 
							noOfParams = 0;
							paramsType.clear();
		  											} 	compound_statement	{
 													  					  
 							$$ = new SymbolInfo();
 							if($2->getName().compare("main") == 0) {
 								$$->code += $2->getName() + " proc\n";
 								
 								$$->code += "mov ax, @DATA\n";
 								$$->code += "mov ds, ax\n";
 								
 								$$->code += $6->code;
 								$$->code += $2->getName() + " endp\n";
 							}
 							else {
 								$$->code += $2->getName() + " proc\n";
 							
	 							$$->code += "push ax\n";
	 							$$->code += "push bx\n";
	 							$$->code += "push cx\n";
	 							$$->code += "push dx\n";
	 							
	 							$$->code += $7->code;
	 							
	 							$$->code += "pop dx\n";
	 							$$->code += "pop cx\n";
	 							$$->code += "pop bx\n";
	 							$$->code += "pop ax\n";
	 							
	 							$$->code += "ret\n" + $2->getName() + " endp\n";
 							}
 																			}
 				;
 								


parameter_list  : parameter_list COMMA type_specifier ID	{
																$4->setVarType($3->getType());
																$4->setIdType("VAR");
																params.push_back($4);
																param.push_back($4);
											  					noOfParams++;
											  					paramsType.push_back($3->getType());
											  				}
 													  					  
				| parameter_list COMMA type_specifier		{ 
											  					noOfParams++;
											  					paramsType.push_back($3->getType());
											  				}
 													  					  
 				| type_specifier ID							{ 
 																$2->setVarType($1->getType());
																$2->setIdType("VAR");
															 	params.push_back($2);
															 	param.push_back($2);
											  					noOfParams++;
 													  			paramsType.push_back($1->getType());
 													  		}
 													  					  
				| type_specifier							{ 
 													  			noOfParams++;
 													  			paramsType.push_back($1->getType());
 													  		}
 				;
 				

 		
compound_statement  : LCURL 													{ 

							table->EnterScope(); 
							for(int i = 0; i < params.size(); i++) {
								if(table->LookUpCurrent(params[i]->getName())==0) {
									table->Insert(params[i]);
									varSec += newVar(params[i]->getName()) + "dw\n";
								}
							}
							params.clear();
						 								}	statements RCURL	{ 
						  					  
	  					  	$$ = $3;
	  					  	table->ExitScope();
	  					  														}
 													  					  
 		    		| LCURL RCURL												{ 
								  					  
	  					 	
	  					  														}
 		    		;
 		    		
 		    		
 		    
var_declaration : type_specifier declaration_list SEMICOLON						{ 

							for(int i = 0; i < vars.size(); i++) vars[i]->setVarType($1->getType());
						  	vars.clear();
						  														}
 		 		;
 		 		
 		 		
 		 
type_specifier	: INT			{
									$$ = new SymbolInfo("int", "INT");
								}

 				| FLOAT			{
 									$$ = new SymbolInfo("float", "FLOAT");
 								}
 				
 				| VOID			{
 									$$ = new SymbolInfo("void", "VOID");
 								}
 				;
 				
 				
 		
declaration_list 	: declaration_list COMMA ID		{ 
										
						if(table->LookUpCurrent($3->getName()) == 0) {
							$3->setIdType("VAR");
					  		table->Insert($3);
					  		vars.push_back($3);
					  		
					  		varSec += newVar($3->getName()) + "dw\n";
					  	}
					  	else {
					  		fprintf(fp3, "Error at Line %d : Multiple declaration of Identifier \"%s\"\n\n",lineCount, $3>getName().c_str());
					  		totalErrors++;
					  	}
													}
 													  
 		  			| declaration_list COMMA ID LTHIRD CONST_INT RTHIRD		{
 		  			
	  					if(table->LookUpCurrent($3->getName()) == 0) {
							$3->setIdType("ARA");
	  						table->Insert($3);
	  						vars.push_back($3);
						  	
						  	varSec += newVar($3->getName()) + "dw " + $5->getName() + " dup (?)\n";
  						}
	  					else {
	  					   	fprintf(fp3, "Error at Line %d : Multiple declaration of Identifier \"%s\"\n\n", lineCount, $3->getName().c_str());
	  						totalErrors++;
	  					}
			  																}
 		  			
 		  			| ID													{
 		  							
  						if(table->LookUpCurrent($1->getName()) == 0) {
							$1->setIdType("VAR");
						  	table->Insert($1);
						  	vars.push_back($1);
						  	
						  	varSec += newVar($1->getName()) + "dw\n";
						}
						else {
							fprintf(fp3, "Error at Line %d : Multiple declaration of Identifier \"%s\"\n\n", lineCount, $1>getName().c_str());
							totalErrors++;
						}
							   												}
		  											  
 		  			| ID LTHIRD CONST_INT RTHIRD							{ 
 		  			
	  					if(table->LookUpCurrent($1->getName()) == 0) {
						  	$1->setIdType("ARA");
						  	table->Insert($1);
						  	vars.push_back($1);
						  	
						  	varSec += newVar($1->getName()) + "dw " + $3->getName() + " dup (?)\n";
						}
						else {
						    fprintf(fp3, "Error at Line %d : Multiple declaration of Identifier \"%s\"\n\n", lineCount, $1->getName().c_str());
						  	totalErrors++;
						}
							  												}
 		  			;
 		  			
 		  			
 		  
statements  : statement								{
														$$ = $1;
													}
 													  
	   		| statements statement					{
	   													$$ = $1;
	   													$$->code += $2->code;
	   												}
	   		;
	   		
	   		
	   
statement 	: var_declaration						{
														
													}
 													  
	  		| expression_statement					{ 
	  													$$ = $1;
	  												}
 													  
	 	 	| compound_statement					{
	 	 												$$ = $1;
	 	 											}
 													  
	  		| FOR LPAREN expression_statement expression_statement expression RPAREN statement	{
	  																			
	  																			$$ = $3;
	  																			string label1 = newLabel();
	  																			string label2 = newLabel();
	  																			$$->code += label1 + ":\n";
	  																			$$->code += "mov ax, " + $4->getName() + "\n";
	  																			$$->code += "cmp ax, 0\n";
	  																			$$->code += "je " + label2 + "\n";
	  																			$$->code += $7->code;
	  																			$$->code += $5->code;
	  																			$$->code += "jmp " + label1 + "\n";
	  																			$$->code += label2 + ":\n";
	  																			
	  																							}					
 													  
	  		| IF LPAREN expression RPAREN statement %prec LOWER_THAN_ELSE	{ 
 													  						 	$$ = $3;
 													  						  	string label = newLabel();
 													  						  	$$->code += "mov ax, " + $3->getName() + "\n";
 													  						  	$$->code += "cmp ax, 0\n";
 													  						  	$$->code += "je " + label + "\n";
 													  						  	$$->code += $5->code;
 													  						  	$$->code += label + ":\n";
 													  					 	}
 													  
	  		| IF LPAREN expression RPAREN statement ELSE statement			{
	  																			$$ = $3;
	  																			string label1 = newLabel();
	  																			string label2 = newLabel();
	  																			$$->code += "mov ax, " + $3->getName() + "\n";
 													  						  	$$->code += "cmp ax, 0\n";
 													  						  	$$->code += "je " + label1 + "\n";
 													  						  	$$->code += $5->code;
 													  						  	$$->code += "jmp " + label2 + "\n";
 													  						  	$$->code += label1 + ":\n";
 													  						  	$$->code += $7->code;
 													  						  	$$->code += label2 + ":\n";
 													  						}
 													  
	  		| WHILE LPAREN expression RPAREN statement						{
	  																			$$ = $3;
	  																			string label1 = newLabel();
	  																			string label2 = newLabel();
	  																			$$->code += label1 + ":\n";
	  																			$$->code += "mov ax, " + $3->getName() + "\n";
	  																			$$->code += "cmp ax, 0\n";
	  																			$$->code += "je " + label2 + "\n";
	  																			$$->code += $5->code;
	  																			$$->code += "jmp " + label1 + "\n";
	  																			$$->code += label2 + ":\n";
	  																		}
 													  
	  		| PRINTLN LPAREN ID RPAREN SEMICOLON							{
	  																			
	  																		}
 													  
	  		| RETURN expression SEMICOLON									{
	  																			$$ = $1;
	  																			$$->code += "mov ax, " + $1->getName() + "\n";	
	  																		}
	  		;
	  		
	  	
	  
expression_statement 	: SEMICOLON					{ 
														
								 					}
 													  
						| expression SEMICOLON 		{
														$$ = $1;
													}
						;
						
						
	  
variable 	: ID 									{ 
														$$ = $1;
 													  	SymbolInfo *temp = table->LookUp($1->getName());
 													  	if(temp == 0) { 
 													  		fprintf(fp3, "Error at Line %d : Undeclared Identifier\n\n", lineCount);
 													  		totalErrors++;
												  		}
 													  	else {
 													  		$$->setVarType(temp->getVarType());
 													  		if(temp->getIdType().compare("ARA") == 0) {
												  				fprintf(fp3, "Error at Line %d : Missing Array-Index on Identifier \"%s\"\n\n",
												  			 			lineCount, $1->getName().c_str()); totalErrors++;
									  			 			}
										  			  }
 													}
 													  
	 		| ID LTHIRD expression RTHIRD			{ 
	 													$$ = $1;
 													  	SymbolInfo *temp = table->LookUp($1->getName());
 													  	if(temp == 0) {
 													  		fprintf(fp3, "Error at Line %d : Undeclared Identifier\n\n", lineCount);
 													  		totalErrors++;
												  		}
 													  	else {
 													  		$$->setVarType(temp->getVarType());
 													  		if($3->getVarType().compare("INT") != 0) {
 													  			fprintf(fp3, "Error at Line %d : Non-Integer Array-Index\n\n", lineCount);
 													  			totalErrors++;
												  			}
												  			if(temp->getIdType().compare("VAR") == 0) {
												  			fprintf(fp3,"Error at Line %d : Using Array-Index on Non-Array Identifier \"%s\"\n\n",
												  			 		lineCount, $1->getName().c_str()); totalErrors++;
										  			 		}
											  		  	}
											  		  	$$->code += $3->code + "mov bx, " + $3->getName() + "\nadd bx, bx\n";
										  		  	}
	 		;
	 		
	 		
	 
 expression : logic_expression						{
 														$$ = $1;
 													}
 													  
	   		| variable ASSIGNOP logic_expression	{
 													 	$$ = $1;
 													 	$$->code += $3->code + $1->code;
 													 	$$->code += "mov ax, " + $3->getName() + "\n";
 													 	if($1->getIdType().compare("ARA")) {
 													 		$$->code += "mov  " + $1->getName() + "[bx], ax\n";
 													 	}
 													 	else {
 													 		$$->code += "mov " + $1->getName() + ", ax\n";
 													 	}
 													 	if(($3->getVarType().compare("FLOAT") == 0) && ($1->getVarType().compare("INT") == 0)) {
 													  		fprintf(fp3, "Warning at Line %d : Floating point number is assigned ", lineCount);
															fprintf(fp3, "to an integer variable\n\n");
															totalErrors++;
														}
												  		if(($3->getVarType().compare("VOID") == 0)) {
 													  		fprintf(fp3, "Error at Line %d : Void function cannot be called in expression\n\n",
 													  	 				lineCount);
 													  	 	totalErrors++;
												  	 	}
 														delete $3;
													}
	   		;
	   		
	   		
			
logic_expression 	: rel_expression				{	
														$$ = $1;
 													}
 													  
		 			| rel_expression LOGICOP rel_expression		{ 
													  			  	$$ = $1;
													  			  	$$->setVarType("INT");
													  			  	$$->code += $3->code;
													  			  	string temp = newTemp();
													  			  	varSec += temp + "dw\n";
													  			  	string label1 = newLabel();
													  			  	string label2 = newLabel();
													  			  	if($2->getName().compare("&&") == 0) {
													  			  		$$->code += "mov ax, " + $1->getName() + "\n";
													  			  		$$->code += "cmp ax, 1\n";
													  			  		$$->code += "jne " + label1 +"\n";
													  			  		$$->code += "mov ax, " + $3->getName() + "\n";
													  			  		$$->code += "cmp ax, 1\n";
													  			  		$$->code += "jne " + label1 +"\n";
													  			  		$$->code += "mov ax, 1\n";
													  			  		$$->code += "mov " + temp + ", ax\n";
													  			  		$$->code += "jmp " + label2 + "\n";
													  			  		$$->code += label1 + ":\n";
													  			  		$$->code += "mov ax, 0\n";
													  			  		$$->code += "mov " + temp + ", ax\n";
													  			  		$$->code += label2 + ":\n";
													  			  	}
													  			  	else {
													  			  		$$->code += "mov ax, " + $1->getName() + "\n";
													  			  		$$->code += "cmp ax, 1\n";
													  			  		$$->code += "je " + label1 +"\n";
													  			  		$$->code += "mov ax, " + $3->getName() + "\n";
													  			  		$$->code += "cmp ax, 1\n";
													  			  		$$->code += "je " + label1 +"\n";
													  			  		$$->code += "mov ax, 0\n";
													  			  		$$->code += "mov " + temp + ", ax\n";
													  			  		$$->code += "jmp " + label2 + "\n";
													  			  		$$->code += label1 + ":\n";
													  			  		$$->code += "mov ax, 1\n";
													  			  		$$->code += "mov " + temp + ", ax\n";
													  			  		$$->code += label2 + ":\n";
													  			  	}
													  			  	$$->setName(temp);
													  			  	delete $2; delete $3;
 													  			}
		 			;
		 			
		 			
			
rel_expression	: simple_expression					{ 
														$$ = $1;
 													}
 													  
				| simple_expression RELOP simple_expression		{ 
 													  				$$ = $1;
 													  				$$->setVarType("INT");
 													  				$$->code += $3->code;
 													  				$$->code += "mov ax, " + $1->getName() + "\n";
 													  				$$->code += "cmp ax, " + $3->getName() + "\n";
 													  				string temp = newTemp();
 													  				varSec += temp + "dw\n";
 													  				string label1 = newLabel();
 													  				string label2 = newLabel();
 													  				if($2->getName().compare("<") == 0) {
 													  					$$->code += "jl " + label1 + "\n";
 													  				}
 													  				else if($2->getName().compare("<=") == 0) {
 													  					$$->code += "jle " + label1 + "\n";
 													  				}
 													  				else if($2->getName().compare(">") == 0) {
 													  					$$->code += "jg " + label1 + "\n";
 													  				}
 													  				else if($2->getName().compare(">=") == 0) {
 													  					$$->code += "jge " + label1 + "\n";
 													  				}
 													  				else if($2->getName().compare("==") == 0) {
 													  					$$->code += "je " + label1 + "\n";
 													  				}
 													  				else {
 													  					$$->code += "jne " + label1 + "\n";
 													  				}
 													  				$$->code += "mov " + temp + ", 0\n";
																	$$->code += "jmp "+ label2 + "\n";
																	$$->code += label1 + ":\nmov " + temp + ", 1\n";
																	$$->code += label2 + ":\n";
																	$$->setName(temp);
																	delete $2; delete $3;
 													  			}
				;
				
				
				
simple_expression 	: term 							{	
														$$ = $1;
 													}
 													  
		  			| simple_expression ADDOP term	{ 
		  												$$ = $1;
		  												$$->code += $3->code;
		  												string temp = newTemp();
		  												varSec += temp + "dw\n";
		  												$$->code += "mov ax, " + $1->getName() + "\n";
	 													if($2->getName().compare("+") == 0) {
	 														$$->code += "add ax, " + $3->getName();
															$$->code += "mov "+ temp + ", ax\n";
														}
														else {
	 														$$->code += "sub ax, " + $3->getName();
															$$->code += "mov "+ temp + ", ax\n";
														}
														$$->setName(temp);
													  	if($1->getVarType().compare("FLOAT") == 0) $$->setVarType($1->getVarType());
													  	else $$->setVarType($3->getVarType());
													  	if($1->getVarType().compare("VOID") == 0) $$->setVarType($1->getVarType());
													  	delete $2; delete $3;
 													}
		  			;
		  			
		  			
					
term :	unary_expression							{	
														$$ = $1;
 													}
 													  
		 |  term MULOP unary_expression				{ 
	 													$$ = $1;
	 													$$->code += $3->code;
	 													$$->code += "mov ax, " + $1->getName() + "\n";
	 													$$->code += "mov bx, " + $3->getName() + "\n";
	 													string temp = newTemp();
	 													varSec += temp + "dw\n";
	 													if($2->getName().compare("*") == 0) {
	 														$$->code += "mul bx\n";
															$$->code += "mov "+ temp + ", ax\n";
														}
														else if($2->getName().compare("/") == 0) {
															$$->code += "xor dx, dx\n";
															$$->code += "div bx\n";
															$$->code += "mov " + temp + ", ax\n";
														}
														else{
															$$->code += "xor dx, dx\n";
															$$->code += "div bx\n";
															$$->code += "mov " + temp + ", dx\n";
														}
														$$->setName(temp);
 													  	if($1->getVarType().compare("FLOAT") == 0) $$->setVarType($1->getVarType());
 													  	else $$->setVarType($3->getVarType());
 													  	if($1->getVarType().compare("VOID") == 0) $$->setVarType($1->getVarType());
 													  	if($2->getName().compare("%") == 0) {
	 													  	if(($1->getVarType().compare("INT") != 0) || ($3->getVarType().compare("INT") != 0)) {
		 													  		fprintf(fp3, "Error at Line %d : Non-Integer Operand on Modulas Operator\n\n",
		 													  		 			lineCount); totalErrors++;
		 													}
									  		 			}
									  		 			delete $2; delete $3;
	 												}
     ;
     
     

unary_expression 	: ADDOP unary_expression		{	
														$$->setVarType($2->getVarType());
														$$ = $2;
														if($2->getName().compare("-") == 0) {
															string temp = newTemp();
															varSec += temp + "dw\n";
			 												$$->code += "mov ax, " + $2->getName() + "\n";
			 												$$->code += "neg ax\n"
			 												$4->code += "mov " + temp + ", ax\n";
			 												$$->setName(temp);
														}
														delete $1;
 													}
 													  
		 			| NOT unary_expression			{	
		 												$$->setVarType($2->getVarType());
		 												$$ = $2;
		 												string temp = newTemp();
		 												varSec += temp + "dw\n";
		 												$$->code += "mov ax, " + $2->getName() + "\n";
		 												$$->code += "not ax\n"
		 												$$->code += "mov " + temp + ", ax\n";
		 												$$->setName(temp);
	 												}
 													  
 													  
		 			| factor						{	
		 												$$ = $1;
													}
		 			;
		 			
		 			
	
factor	: variable									{	
														$$ = $1;
 														if($$->getIdType().compare("ARA") == 0) {
 															string temp = newTemp();
 															varSec += temp + "dw\n";
 															$$->code += "mov ax, " + $1->getName() + "[bx]\n";
 															$$->code += "mov " + temp + ", ax\n";
 															$$->setName(temp);
														}
													}
 													  
		| ID LPAREN argument_list RPAREN			{ 
											
				$$ = new SymbolInfo();
				  
				  
				SymbolInfo *temp = table->LookUp($1->getName());
				  
			  	if(temp == 0) {
			  		fprintf(fp3, "Error at Line %d : Undeclared Identifier \"%s\"\n\n", lineCount, $1->getName().c_str());
			  		totalErrors++;
			  	}
  				else if(temp->funcInfo == 0) {
  					fprintf(fp3, "Error at Line %d : Function call with non-function identifier\n\n", lineCount);
  					totalErrors++;
			  	}
			  	  
			  	else {
				  
					if(temp->funcInfo->NumberOfParam > noOfArgs) {
				  		fprintf(fp3, "Error at Line %d : Too few arguments\n\n", lineCount);
				  		totalErrors++;
			  	  	}
			  	  	if(temp->funcInfo->NumberOfParam < noOfArgs) {
			  	  		fprintf(fp3, "Error at Line %d : Too many arguments\n\n", lineCount);
			  	  		totalErrors++;
		  	  	  	}
		  	  	  	else {
		  	  	  		for(int i = 0; i < temp->funcInfo->NumberOfParam; i++) {
		  	  	  			$$->code += "mov ax, " + argsList[i]->getName() + "\n";
		  	  	  			$$->code += "mov " +  temp->funcInfo->parameters[i] + ", ax\n";
		  	  	  		}
		  	  	  		$$->code += "call " + $1->getName() + "\n";
		  	  	  		if(temp->funcInfo->retType.compare("void") != 0) {
		  	  	  			string temp = newTemp();
							varSec += temp + "dw\n";
							$$->code += "mov " + temp + ", ax\n";
							$$->setName(temp);
		  	  	  		}
		  	  	  	}
		  	  	  	for(int i = 0; (i < temp->funcInfo->paramList.size() && i < argsType.size()); i++) {
		  	  	  		if(temp->funcInfo->paramList[i].compare(argsType[i]) != 0) {
		  	  	  			fprintf(fp3, "Error at Line %d : Type Mismatch in argument\n\n", lineCount);
		  	  	  			totalErrors++;
	  	  	  			}
  	  	  		  	}
  	  	  		  	$$->setVarType(temp->funcInfo->retType);
  	  	  		}
  	  	  		  
  	  	  		  noOfArgs = 0;
  	  	  		  argsType.clear();
 													}
 													  
		| LPAREN expression RPAREN					{ 	
														$$ = $2;
													}
 													  
		| CONST_INT									{	
														$$ = $1;
													}
 													  
		| CONST_FLOAT								{	
														$$ = $1;
													}
 													  
		| variable INCOP							{
														$$ = $1;
														if($1->getIdType().compare("ARA") != 0) {
															
															string temp = newTemp();
															varSec += temp + " dw\n";
															if($2->getName().compare("++") == 0) {
																$$->code += "inc " + temp + "\n";
															}
															else {
																$$->code += "dec " + temp + "\n";
															}
															$$->setName(temp);	
														}
														
 													}
		;
		
		
	
argument_list : arguments							{ 
														
													}
 													
			  |										{
			  										
			  										}
			  ;
	
arguments : arguments COMMA logic_expression		{ 
														argsList.push_back($3);
 													  
 													  	noOfArgs++;
 													  	argsType.push_back($3->getVarType());
 													}
 													  
	      | logic_expression						{ 
	      												argsList.push_back($1);
 													  
 													  	noOfArgs++;
 													  	argsType.push_back($1->getVarType());
 													}
	      ;
 

%%
int main(int argc,char *argv[])
{

	if((fp=fopen(argv[1],"r"))==NULL) {
		printf("Cannot Open Input File.\n");
		exit(1);
	}

	fp2= fopen(argv[2],"w");
	fp3= fopen(argv[3],"w");

	table = new SymbolTable(SIZE_OF_BUCKET);	

	yyin=fp;
	yyparse();
	
	fclose(fp2);
	fclose(fp3);
	
	return 0;
}

