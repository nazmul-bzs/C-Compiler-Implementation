%option noyywrap

%x STRING_STATE
%x S_COMMENT_STATE
%x M_COMMENT_STATE



%{
	#include<bits/stdc++.h>
	#include "1505037_symboltable.h"
	#define SIZE_OF_BUCKET 100

	FILE *logOut;
	FILE *tokenOut;
	
	SymbolTable *s;
	
	int lineCount = 1;
	int errorCount = 0;
	
	string stringProcess = "";
	int stringInitLine = 0;

	string commentProcess = "";
	int commentInitLine = 0;

%}



WHITESPACE	[ \t\f\r\v]+

NEWLINE 	\n

ID		[a-zA-Z_][0-9a-zA-Z_]*
NUMBER		[0-9]

IS		{NUMBER}+{ID}+

CHAR		[ -~]{-}['\\]
CHARACTER	('({CHAR})')
SPECIAL_CHAR	'\\[ntafrbv0\"\\]'

MCE		('({CHAR}{CHAR}+)')
UCE		('({CHAR})*)

MSCE		'\\[^\n][^\n]+'
USCE		'\\([^\n]{-}[^'])*|'\\'

FLOAT		([0-9]+)?\.[0-9]+(E[+-]?[0-9]+)?

DPE		([0-9]+)?\.[0-9]*([\.]*[0-9]*)+(E[+-]?[0-9]+\.[0-9]*)?

IFN		([0-9]+)?\.[0-9]*([\.]*[0-9]*)+(E[+-]?[0-9]*\.[0-9]*)?




%%

{WHITESPACE}	{ /*do nothing*/ }



{NEWLINE}	{ lineCount++; }



"if"		{ fprintf(logOut, "Line No. %d : Token <IF> Lexeme %s found\n\n", lineCount, yytext);
		  fprintf(tokenOut, "<IF>\t"); }



"else"		{ fprintf(logOut, "Line No. %d : Token <ELSE> Lexeme %s found\n\n", lineCount, yytext);
		  fprintf(tokenOut, "<ELSE>\t"); }



"for"		{ fprintf(logOut, "Line No. %d : Token <FOR> Lexeme %s found\n\n", lineCount, yytext);
		  fprintf(tokenOut, "<FOR>\t"); }



"while"		{ fprintf(logOut, "Line No. %d : Token <WHILE> Lexeme %s found\n", lineCount, yytext);
		  fprintf(tokenOut, "<WHILE>\t"); }



"do"		{ fprintf(logOut, "Line No. %d : Token <DO> Lexeme %s found\n\n", lineCount, yytext);
		  fprintf(tokenOut, "<DO>\t"); }



"break"		{ fprintf(logOut, "Line No. %d : Token <BREAK> Lexeme %s found\n", lineCount, yytext);
		  fprintf(tokenOut, "<BREAK>\t"); }



"int"		{ fprintf(logOut, "Line No. %d : Token <INT> Lexeme %s found\n\n", lineCount, yytext);
		  fprintf(tokenOut, "<INT>\t"); }



"char"		{ fprintf(logOut, "Line No. %d : Token <CHAR> Lexeme %s found\n\n", lineCount, yytext);
		  fprintf(tokenOut, "<CHAR>\t"); }



"float"		{ fprintf(logOut, "Line No. %d : Token <FLOAT> Lexeme %s found\n\n", lineCount, yytext);
		  fprintf(tokenOut, "<FLOAT>\t"); }



"double"	{ fprintf(logOut, "Line No. %d : Token <DOUBLE> Lexeme %s found\n\n", lineCount, yytext);
		  fprintf(tokenOut, "<DOUBLE>\t"); }



"void"		{ fprintf(logOut, "Line No. %d : Token <VOID> Lexeme %s found\n\n", lineCount, yytext);
		  fprintf(tokenOut, "<VOID>\t"); }



"return"	{ fprintf(logOut, "Line No. %d : Token <RETURN> Lexeme %s found\n\n", lineCount, yytext);
		  fprintf(tokenOut, "<RETURN>\t"); }



"switch"	{ fprintf(logOut, "Line No. %d : Token <SWITCH> Lexeme %s found\n\n", lineCount, yytext);
		  fprintf(tokenOut, "<SWITCH>\t"); }



"case"		{ fprintf(logOut, "Line No. %d : Token <CASE> Lexeme %s found\n\n", lineCount, yytext);
		  fprintf(tokenOut, "<CASE>\t"); }



"default"	{ fprintf(logOut, "Line No. %d : Token <DEFAULT> Lexeme %s found\n\n", lineCount, yytext);
		  fprintf(tokenOut, "<DEFAULT>\t"); }



"continue"	{ fprintf(logOut, "Line No. %d : Token <CONTINUE> Lexeme %s found\n\n", lineCount, yytext);
		  fprintf(tokenOut, "<CONTINUE>\t"); }



"+"		|
"-"		{ fprintf(logOut, "Line No. %d : Token <ADDOP> Lexeme %s found\n\n", lineCount, yytext);
		  fprintf(tokenOut, "<ADDOP, %s>\t", yytext); }



"*"		|
"/"		|
"%"		{ fprintf(logOut, "Line No. %d : Token <MULOP> Lexeme %s found\n\n", lineCount, yytext);
		  fprintf(tokenOut, "<MULOP, %s>\t", yytext); }



"++"		|
"--"		{ fprintf(logOut, "Line No. %d : Token <INCOP> Lexeme %s found\n\n", lineCount, yytext);
		  fprintf(tokenOut, "<INCOP, %s>\t", yytext); }



"<"		|
"<="		|
">"		|
">="		|
"=="		|
"!="		{ fprintf(logOut, "Line No. %d : Token <RELOP> Lexeme %s found\n\n", lineCount, yytext);
		  fprintf(tokenOut, "<RELOP, %s>\t", yytext); }



"="		{ fprintf(logOut, "Line No. %d : Token <ASSIGNOP> Lexeme %s found\n\n", lineCount, yytext);
		  fprintf(tokenOut, "<ASSIGNOP, %s>\t", yytext); }



"&&"		|
"||"		{ fprintf(logOut, "Line No. %d : Token <LOGICOP> Lexeme %s found\n\n", lineCount, yytext);
		  fprintf(tokenOut, "<LOGICOP, %s>\t", yytext); }



"&"		|
"|"		|
"^"		|
"<<"		|
">>"		{ fprintf(logOut, "Line No. %d : Token <BITOP> Lexeme %s found\n\n", lineCount, yytext);
		  fprintf(tokenOut, "<BITOP, %s>\t", yytext); }



"!"		{ fprintf(logOut, "Line No. %d : Token <NOT> Lexeme %s found\n\n", lineCount, yytext);
		  fprintf(tokenOut, "<NOT, %s>\t", yytext); }



"("		{ fprintf(logOut, "Line No. %d : Token <LPAREN> Lexeme %s found\n\n", lineCount, yytext);
		  fprintf(tokenOut, "<LPAREN, %s>\t", yytext); }



")"		{ fprintf(logOut, "Line No. %d : Token <RPAREN> Lexeme %s found\n\n", lineCount, yytext);
		  fprintf(tokenOut, "<RPAREN, %s>\t", yytext); }



"{"		{ fprintf(logOut, "Line No. %d : Token <LCURL> Lexeme %s found\n\n", lineCount, yytext);
		  fprintf(tokenOut, "<LCURL, %s>\t", yytext); }



"}"		{ fprintf(logOut, "Line No. %d : Token <RCURL> Lexeme %s found\n\n", lineCount, yytext);
		  fprintf(tokenOut, "<RCURL, %s>\t", yytext); }



"["		{ fprintf(logOut, "Line No. %d : Token <LTHIRD> Lexeme %s found\n\n", lineCount, yytext);
		  fprintf(tokenOut, "<LTHIRD, %s>\t", yytext); }



"]"		{ fprintf(logOut, "Line No. %d : Token <RTHIRD> Lexeme %s found\n\n", lineCount, yytext);
		  fprintf(tokenOut, "<RTHIRD, %s>\t", yytext); }



","		{ fprintf(logOut, "Line No. %d : Token <COMMA> Lexeme %s found\n\n", lineCount, yytext);
		  fprintf(tokenOut, "<COMMA, %s>\t", yytext); }



";"		{ fprintf(logOut, "Line No. %d : Token <SEMICOLON> Lexeme %s found\n\n", lineCount, yytext);
		  fprintf(tokenOut, "<SEMICOLON, %s>\t", yytext); }




{CHARACTER}	{ fprintf(logOut, "Line No. %d : Token <CONST_CHAR> Lexeme %s found\n\n", lineCount, yytext);
		  char temp[1];
		  temp[0] = yytext[1];
		  fprintf(tokenOut, "<CONST_CHAR, %s>\t", temp);

		  SymbolInfo *newNode = new SymbolInfo();
		  newNode->setName(yytext);
		  newNode->setType("CONST_CHAR");
		  newNode->next = 0;
		  if(s->LookUp(newNode->getName()) == 0) {
			s->Insert(newNode);
			s->PrintCurrent(logOut);
		  } }



{SPECIAL_CHAR}	{ fprintf(logOut, "Line No. %d : Token <CONST_CHAR> Lexeme %s found\n\n", lineCount, yytext);

		  SymbolInfo *newNode = new SymbolInfo();
		  newNode->setName(yytext);
		  newNode->setType("CONST_CHAR");
		  newNode->next = 0;
		  if(s->LookUp(newNode->getName()) == 0) {
			s->Insert(newNode);
			s->PrintCurrent(logOut);
		  }

		  char temp[1];
		
		  switch(yytext[2]) {
			case 'n': temp[0] = '\n'; break;
			case 't': temp[0] = '\t'; break;
			case 'a': temp[0] = '\a'; break;
			case 'f': temp[0] = '\f'; break;
			case 'r': temp[0] = '\r'; break;
			case 'b': temp[0] = '\b'; break;
			case 'v': temp[0] = '\v'; break;
			case '0': temp[0] = '\0'; break;
			case '\"': temp[0] = '\"'; break;
			case '\\': temp[0] = '\\'; break;
			default: break;
		  }
		  //temp[1] = '\0';
		  
		  fprintf(tokenOut, "<CONST_CHAR, %s>\t", temp); }



{MCE}		|
{MSCE}		{ fprintf(logOut, "Error at line No. %d : MUlti character error %s found\n\n", lineCount, yytext);
		  errorCount++; }



{UCE}		|
{USCE}		{ fprintf(logOut, "Error at line No. %d : Unfinished character error %s found\n\n", lineCount, yytext);
		  errorCount++; }



{FLOAT}		{ fprintf(logOut, "Line No. %d : Token <CONST_FLOAT> Lexeme %s found\n\n", lineCount, yytext);
		  fprintf(tokenOut, "<CONST_FLOAT, %s>\t", yytext);
 
		  SymbolInfo *newNode = new SymbolInfo();
		  newNode->setName(yytext);
		  newNode->setType("CONST_FLOAT");
		  newNode->next = 0;
		  if(s->LookUp(newNode->getName()) == 0) {
			s->Insert(newNode);
			s->PrintCurrent(logOut);
		  } }



{DPE}		{ fprintf(logOut, "Error at line No. %d : Too many decimal point %s found\n\n", lineCount, yytext);
		  errorCount++; }



{IFN}		{ fprintf(logOut, "Error at line No. %d : Ill formed munber %s found\n\n", lineCount, yytext);
		  errorCount++; }




"//"		{ BEGIN S_COMMENT_STATE;
		  commentProcess = "";
		  commentInitLine = lineCount; }

<S_COMMENT_STATE>[^\\\n]*	{ commentProcess += yytext; }

<S_COMMENT_STATE>"\\"		{ commentProcess += yytext; }

<S_COMMENT_STATE>"\\\n"		{ lineCount++; }

<S_COMMENT_STATE>"\n"		{ lineCount++;
				  fprintf(logOut, "Line No. %d : Token <COMMENT> Lexeme %s found\n\n", commentInitLine, commentProcess.c_str());
				  BEGIN INITIAL; }



"/*"		{ BEGIN M_COMMENT_STATE;
		  commentProcess = "";
		  commentInitLine = lineCount; }

<M_COMMENT_STATE>[^"*"\n]*	{ commentProcess += yytext; }

<M_COMMENT_STATE>("*"[^/\n])*	{ commentProcess += yytext; }

<M_COMMENT_STATE>"*\n"		{ commentProcess += yytext;
				  lineCount++; }

<M_COMMENT_STATE>"\n"		{ lineCount++; }

<M_COMMENT_STATE>"*/"		{ fprintf(logOut, "Line No. %d : Token <COMMENT> Lexeme %s found\n\n", commentInitLine, commentProcess.c_str());
				  BEGIN INITIAL; }

<M_COMMENT_STATE><<EOF>>	{ fprintf(logOut, "Error at line No. %d : Unfinished comment %s found\n\n", lineCount-1, commentProcess.c_str());
		  		  errorCount++;
				  BEGIN INITIAL; }




\"		{ BEGIN STRING_STATE;
		  stringProcess = "";
		  stringProcess += yytext;
		  stringInitLine = lineCount; }

<STRING_STATE>[^\\\"\n]* { stringProcess += yytext; }

<STRING_STATE>\\	{ stringProcess += yytext; }

<STRING_STATE>\\\"	{ stringProcess += yytext; }

<STRING_STATE>\\\n	{ lineCount++; }

<STRING_STATE>\"	{ stringProcess += yytext;
			  fprintf(logOut, "Line No. %d : Token <STRING> Lexeme %s found\n\n", stringInitLine, stringProcess.c_str());

			  int len = stringProcess.length();
			  char *temp = new char[len+1];
			  temp[0] = stringProcess[0];
			  temp[len] = '\0';
			  
			  int j = 1;
			  for(int i = 1; i < len; i++) {
				if(stringProcess[i] == '\\') {
					switch(stringProcess[i+1]) {
					case 'n': temp[j] = '\n'; j++; i++ ; break;
					case 't': temp[j] = '\t'; j++; i++; break;
					case 'a': temp[j] = '\a'; j++; i++; break;
					case 'f': temp[j] = '\f'; j++; i++; break;
					case 'r': temp[j] = '\r'; j++; i++; break;
					case 'b': temp[j] = '\b'; j++; i++; break;
					case 'v': temp[j] = '\v'; j++; i++; break;
					case '0': temp[j] = '\0'; j++; i++; break;
					case '\"': temp[j] = '\"'; j++; i++; break;
					case '\\': temp[j] = '\\'; j++; i++; break;
					default: break;
		  			}
				}
				else {
				     temp[j] = stringProcess[i];
				     j++;
				}
			  }

			  temp[j] = '\0';	

		  	  fprintf(tokenOut, "<STRING, %s>\t", temp);
			  BEGIN INITIAL; }

<STRING_STATE>"\n"	{ fprintf(logOut, "Error at line No. %d : Unfinished string %s found\n\n", lineCount, stringProcess.c_str());
			  lineCount++;
		  	  errorCount++;
			  BEGIN INITIAL; }






{ID}		{ fprintf(logOut, "Line No. %d : Token <ID> Lexeme %s found\n\n", lineCount, yytext);
		  fprintf(tokenOut, "<ID, %s>\t", yytext);
 
		  SymbolInfo *newNode = new SymbolInfo();
		  newNode->setName(yytext);
		  newNode->setType("ID");
		  newNode->next = 0;
		  if(s->LookUp(newNode->getName()) == 0) {
			s->Insert(newNode);
			s->PrintCurrent(logOut);
		  } }



{NUMBER}+	{ fprintf(logOut, "Line No. %d : Token <CONST_INT> Lexeme %s found\n\n", lineCount, yytext);
		  fprintf(tokenOut, "<CONST_INT, %s>\t", yytext);
 
		  SymbolInfo *newNode = new SymbolInfo();
		  newNode->setName(yytext);
		  newNode->setType("CONST_INT");
		  newNode->next = 0;
		  if(s->LookUp(newNode->getName()) == 0) {
			s->Insert(newNode);
			s->PrintCurrent(logOut);
		  } }



{IS}		{ fprintf(logOut, "Error at line No. %d : Invalid suffix %s found\n\n", lineCount, yytext);
		  errorCount++; }




.		{ fprintf(logOut, "Error at line No. %d : Unrecognized character %s\n\n", lineCount, yytext); }


%%




int main(int argc, char* argv[]) {

	if(argc != 2) {
		printf("Please input filename\n");
		return 0;
	}

	FILE *in;

	in = fopen(argv[1], "r");
	if(in == NULL) {
		printf("Can't open file\n");
		return 0;
	}

	s = new SymbolTable(SIZE_OF_BUCKET);

	logOut = fopen("1505037_log.txt", "w");
	tokenOut = fopen("1505037_token.txt", "w");
	
	yyin = in;
	yylex();
	fprintf(logOut, "Total line(s) %d\n\n", --lineCount);
	fprintf(logOut, "Totla error(s) %d\n\n", errorCount);

	printf("Total line(s) %d\n", lineCount);
	printf("Totla error(s) %d\n", errorCount);
	fclose(yyin);

	fclose(logOut);
	fclose(tokenOut);
	return 0;

//STRING	(\"([^\"\n]|\\[\n])*\")
//USE		(\"([^\"\n]|\\[\n])*)
//S_COMMENT	"//"[^\n]*$
//M_COMMENT	("/*"([^"*"]|"*"[^"/"])+"*/")
//UME		("/*"([^"*"]|"*"[^"/"])+)

}
