set_operators:-
	op(200,xfy,∨),
	op(200,xfy,∧),
	op(100,xfy,≥),
	op(100,xfy,≤),
	op(100,xfy,#),
	op(100,xfy,¨),
	op(100,xfy,≠),
	op(100,xfy,$),	
	op(200,xfy,⇒),
	op(100, fx,¬). 

:-set_operators.

board :- 
	brush_colours,
	create_board,
	window_handler( board, board_handler ),  
	show_dialog(board),
	font.

abortar:- repeat, flag(1), wait(0), fail.

size(0,small).
size(1,medium).
size(2,big).
	
intersection([], _, []).
intersection([X|Xs], Ys, Ws):-  member(X, Ys), !, Ws = [X|Zs], intersection(Xs, Ys, Zs).
intersection([_|Xs], Ys, Zs):-intersection(Xs, Ys, Zs).

union([], Ys, Ys).
union([X|Xs], Ys, Zs):-member(X, Ys), !, union(Xs, Ys, Zs).
union([X|Xs], Ys, [X|Zs]):-union(Xs, Ys, Zs).

difference([], _, []).
difference([X|Xs], Ys, Zs):-member(X, Ys), !, difference(Xs, Ys, Zs).
difference([X|Xs], Ys, [X|Zs]):-difference(Xs, Ys, Zs).

arrange([],_):-!.

arrange([A|B],[Color,Shape,Size,Cell]):- 	
	Colors = [red,blue,yellow,cyan,green],
	Shapes = [square,triangle,circle],
	Sizes = [big,medium,small],
	(member(A,Colors)->Color = A;!),
	(member(A,Shapes)->Shape = A;!),
	(member(A,Sizes)->Size = A;!),
	(type(A,8)-> Cell= A;!),
	arrange(B,[Color,Shape,Size,Cell]).

arrange([A|B],[Color,Shape,Size]):- 	
	Colors = [red,blue,yellow,cyan,green],
	Shapes = [square,triangle,circle],
	Sizes = [big,medium,small],
	(member(A,Colors)->Color = A;!),
	(member(A,Shapes)->Shape = A;!),
	(member(A,Sizes)->Size = A;!),
	arrange(B,[Color,Shape,Size]).

%%%	Convierte el texto de la figura de representacion visual [Color,Shape,Size,(X,Y)] a representación interno [Color,Shape,Size,Cell]
cell_to_external([Color,Shape,SizeN,Cell],[Color,Shape,SizeL,(X,Y)]):-	size(SizeN,SizeL),cell_to_coords(Cell,Row,Col),	X is +(1,Col),Y is +(1,Row).
cell_to_internal([Color,Shape,SizeN,Cell],[Color,Shape,SizeL,(X,Y)]):-	size(SizeN,SizeL),Row is -(X,1), Col is -(Y,1),	coords_to_cell(Cell,Col,Row).	

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		%%%		Operaciones logicas		%%%
		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% 	Operacion: Existe
∃(X:Filter1 \ Cond:S):-  

	arrange(Filter1,[Color,Shape,Size,((I,J),CFilter)]),
	atom_string(X,XS),
	(atom(Size)->size(NSize,Size);	\+(atom(Size))->NSize=_),
	get_memory(Shapes), 
	findall([Color,Shape,NSize,Cell],member([Color,Shape,NSize,Cell],Shapes),FilterI),
	(callable(CFilter)->(
			findall((I,J),cell_filter((I,J),CFilter),CellList),
			get_cell_filter(CellList,FilterCell), 
			intersect_cell(FilterI,FilterCell,Filter)	
		);(Filter = FilterI)),
	write(Cond)~>SCond, write(S)~> SS,
	set_false, 
	forall(member([C,For,T,Coo],Filter),
			(		
				get_temp_memory(PrevShapes),
				cell_to_external([C,For,T,Coo],ShapeS),
				get_truth_value(PrevBool),
				string_replace_all(SCond,XS,ShapeS,FSCond), string_replace_all(SS,XS,ShapeS,FSS),
				cade_dato(FSCond,FCond),
				(callable(S)->cade_dato(FSS,FS),FCond ∧ FS ; call(FCond),!),
				get_truth_value(Bool),
				or(PrevBool,Bool),
				get_temp_memory(RShapes), 
				(Bool == `TRUE` -> union(PrevShapes,RShapes,FShapes),set_temp_memory(FShapes);set_temp_memory(PrevShapes))				
			)
		). 

cell_filter((I,J),A):-
	findall(S,integer_bound(1,S,10),Ints),  
	member(Y,Ints),
	member(X,Ints), 
	I is X,
	J is Y,
	call(A)  .

get_cell_filter(CellList,Filter):-
	wtext((board,5000),SMem),cade_dato(SMem,Mem),
	findall([Color,Shape,Size,(I,J)],(
		member([Color,Shape,Size,(I,J)],Mem),
		member((I,J),CellList)
	),Filter).

intersect_cell(FilterI,FilterCell,Filter):-
	wtext((board,6100),`[]`),
	forall(member(CellF,FilterCell),
			(
				wtext((board,6100),LIs),cade_dato(LIs,LI),
				cell_to_internal(IntCell,CellF),	
				append(LI,[IntCell],LF),
				write(LF)~>LFs, wtext((board,6100),LFs)	
			)
		),
	wtext((board,6100),L),cade_dato(L,Lista),
	intersection(Lista, FilterI, Filter).



%%%	Operacion: Para todo


∀(X:Filter1\ Cond:S):- 
	wtext((board,6101),`[]`),
	arrange(Filter1,[Color,Shape,Size,((I,J),CFilter)]),
	atom_string(X,XS),
	(atom(Size)->size(NSize,Size);	\+(atom(Size))->NSize=_),
	get_memory(Shapes), 
	findall([Color,Shape,NSize,Cell],member([Color,Shape,NSize,Cell],Shapes),FilterI),
	(callable(CFilter)->(
			findall((I,J),cell_filter((I,J),CFilter),CellList),
			get_cell_filter(CellList,FilterCell), 
			intersect_cell(FilterI,FilterCell,Filter)	
		);(Filter = FilterI);!),
	write(Cond)~>SCond, write(S)~> SS,	
	set_true,
	forall(member([C,For,T,Coo],Filter),
			(
				get_temp_memory(PrevShapes),
				cell_to_external([C,For,T,Coo],ShapeS),
				get_truth_value(PrevBool),
				string_replace_all(SCond,XS,ShapeS,FSCond), string_replace_all(SS,XS,ShapeS,FSS),
				cade_dato(FSCond,FCond), 
				(callable(S)->cade_dato(FSS,FS),(FCond ⇒ FS) ; call(FCond),!),
				get_truth_value(Bool), 
				and(PrevBool,Bool),
				get_temp_memory(RShapes),
				(Bool == `TRUE` -> union(PrevShapes,RShapes,FShapes),
				set_temp_memory(FShapes);(set_temp_memory([]),set_shape_error([C,For,T,Coo])))
			)
		),
	(get_truth_value(B),B == `FALSE` -> set_temp_memory([]);!).

set_shape_error([Color,Figura,Size,N]):-
	wtext((board,6101),Text), cade_dato(Text,MemI),
	append(MemI,[[Color,Figura,Size,N]],Lis),
	write(Lis)~> MemF,
	wtext((board,6101),MemF),
	Figura(Size,N,Color,40,_,_).
%%%	Operacion:	AND ∧
A ∧ B :- call(A), get_temp_memory(SA), call(B),get_temp_memory(SB),intersection(SA,SB,IS),set_temp_memory(IS), set_truth_value.

%%%	Operacion:	OR ∨
A ∨ B :- call(A), get_temp_memory(SA), call(B),get_temp_memory(SB),union(SA,SB,IS),set_temp_memory(IS), set_truth_value.

%%%	Operacion:	menor o igual que
atMost([ColorA,ShapeA,SizeA,CellA] , [_,_,SizeB,_]) :- size(SA,SizeA), size(SB,SizeB),cell_to_internal(Shape,[ColorA,ShapeA,SizeA,CellA]),( SA =< SB -> set_true,set_temp_memory([Shape]); set_false). 

atMost([ColorA,ShapeA,SizeA,CellA] , Size) :- size(SA,SizeA),size(S,Size),cell_to_internal(Shape,[ColorA,ShapeA,SizeA,CellA]),(SA =< S ->set_true,set_temp_memory([Shape]); set_false).

%%%	Operacion:	mayor o igual que
atLeast([ColorA,ShapeA,SizeA,CellA] , [_,_,SizeB,_]) :- size(SA,SizeA), size(SB,SizeB),cell_to_internal(Shape,[ColorA,ShapeA,SizeA,CellA]),( SA >= SB -> set_true,set_temp_memory([Shape]); set_false).

atLeast([ColorA,ShapeA,SizeA,CellA] , Size ):- size(SA,SizeA),size(S,Size),cell_to_internal(Shape,[ColorA,ShapeA,SizeA,CellA]),(SA >= S ->set_true,set_temp_memory([Shape]); set_false).


%%%	Operacion:	mayor que

greaterThan([ColorA,ShapeA,SizeA,CellA] , [_,_,SizeB,_] ):- size(SA,SizeA), size(SB,SizeB),cell_to_internal(Shape,[ColorA,ShapeA,SizeA,CellA]),( SA > SB -> set_true,set_temp_memory([Shape]); set_false).
greaterThan([ColorA,ShapeA,SizeA,CellA] , Size) :- size(SA,SizeA),size(S,Size),cell_to_internal(Shape,[ColorA,ShapeA,SizeA,CellA]),(SA > S ->set_true,set_temp_memory([Shape]); set_false).


%%%	Operacion:	menor que
lessThan([ColorA,ShapeA,SizeA,CellA] , [_,_,SizeB,_]) :- size(SA,SizeA), size(SB,SizeB),cell_to_internal(Shape,[ColorA,ShapeA,SizeA,CellA]),( SA < SB -> set_true,set_temp_memory([Shape]); set_false).
lessThan([ColorA,ShapeA,SizeA,CellA] , Size) :- size(SA,SizeA),size(S,Size),cell_to_internal(Shape,[ColorA,ShapeA,SizeA,CellA]),(SA < S ->set_true,set_temp_memory([Shape]); set_false).


%%%	Operacion:	diferente
different([ColorA,ShapeA,SizeA,CellA], [ColorB,ShapeB,SizeB,_] ):- 	(ColorA \== ColorB ; ShapeA\==ShapeB; SizeA\==SizeB) -> (set_true,cell_to_internal(Shape,[ColorA,ShapeA,SizeA,CellA]),set_temp_memory([Shape]));set_false.

%%%	Operacion:	igual
equal([ColorA,ShapeA,SizeA,CellA] , [ColorB,ShapeB,SizeB,_] ):- 	(ColorA == ColorB, ShapeA == ShapeB, SizeA == SizeB) -> (set_true,cell_to_internal(Shape,[ColorA,ShapeA,SizeA,CellA]),set_temp_memory([Shape]));set_false.

%%%	Operacion:	entonces - implicación
A ⇒ B :- call(A), get_truth_value(TA), get_temp_memory(MemA), call(B),get_truth_value(TB),then(TA,TB), get_truth_value(Bool),Bool == `TRUE` -> set_temp_memory(MemA);!. 

%%%	Operacion: negación
¬ A :- get_memory(Memory),call(A),get_temp_memory(TMemory),difference(Memory,TMemory,Result),set_temp_memory(Result),set_truth_value.

%%%	Opercion: es
 ¿([ColorA,ShapeA,SizeA,Cell],[]):- set_true, cell_to_internal(ShapeS,[ColorA,ShapeA,SizeA,Cell]),set_temp_memory([ShapeS]).

 ¿([ColorA,ShapeA,SizeA,Cell], Filter):-
	arrange(Filter,[ColorB,ShapeB,SizeB]),
	set_true, 
	(atom(ColorB) -> 	(
					get_truth_value(Color),
					(
						
						ColorA==ColorB->and(Color,`TRUE`);and(Color,`FALSE`)
					)
				);!),
	(atom(ShapeB) -> 	(
					
					get_truth_value(Shape),

					(
						ShapeA==ShapeB->and(Shape,`TRUE`);and(Shape,`FALSE`)
					)
				);!),
	(atom(SizeB) -> 	(
					get_truth_value(Size),
					(
						SizeA==SizeB->and(Size,`TRUE`);and(Size,`FALSE`)
					)
				);!),
	get_truth_value(Bool),
	(Bool == `TRUE`->(cell_to_internal(ShapeS,[ColorA,ShapeA,SizeA,Cell]),set_temp_memory([ShapeS]));
	Bool == `FALSE`-> set_temp_memory([])).
		
		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		%%%		Tablas de verdad		%%%
		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
and(`TRUE`,`TRUE`):- set_true.
and(_,`FALSE`) :- set_false.
and(`FALSE`,_):- set_false.

or(`TRUE`,_) :- set_true.
or(_,`TRUE`) :- set_true.
or(`FALSE`,`FALSE`) :- set_false.

then(`TRUE`,`TRUE`):- set_true.
then(`TRUE`,`FALSE`):- set_false.
then(`FALSE`,_) :- set_true.

¬(`TRUE`):- set_false.
¬(`FALSE`):- set_true.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

set_true:-wtext((board,11000),`TRUE`),rich_format( (board,11000), all, [color=(70,170,70),size=250,bold=1] ).
set_false:-wtext((board,11000),`FALSE`),rich_format( (board,11000), all, [color=(255,0,0),size=250,bold=1] ).
set_error:-wtext((board,11000),`INPUT ERROR`),rich_format( (board,11000), all, [color=(0,0,0),size=250,bold=1]) ,wshow((board,11000),1).

%%%		Devuelve el valor de verdad resultado de la ultiam operacion dada
get_truth_value(Bool):- wtext((board,11000),Bool).
set_truth_value:- get_temp_memory(Temp), Temp= [] -> set_false;set_true.

%%%		Retorna las figuras que comple las condiciones que estan a la izquierda de la figura indicada
rightOf([ColorAI,ShapeAI,SizeAI,CellAI],[ColorBI,ShapeBI,SizeBI,CellBI]):-
	cell_to_internal([ColorAF,ShapeAF,SizeAF,CellAF],[ColorAI,ShapeAI,SizeAI,CellAI]),cell_to_internal([ColorBF,ShapeBF,SizeBF,CellBF],[ColorBI,ShapeBI,SizeBI,CellBI]),
	set_temp_memory([]),
	cell_to_coords(CellAF,I,J), JC is -(J,1),
	findall(X,integer_bound(0,X, JC),LCells)		,
	get_memory(Shapes),
	forall(member(Col,LCells),
			(
				coords_to_cell(Cell2,I,Col), 
				member([_,_,_,Cell2],Shapes,D),member(Shape,Shapes,D),
				Shape = [ColorBF,ShapeBF,SizeBF,CellBF] ->set_temp_memory([[ColorAF,ShapeAF,SizeAF,CellAF]]);!			
				
		)	
		),set_truth_value.

rightOf([ColorI,ShapeI,SizeI,CellI],Filter):-
	arrange(Filter,[Color,Shape,Size]),
	cell_to_internal([ColorA,ShapeA,SizeA,Cell],[ColorI,ShapeI,SizeI,CellI]),
	set_temp_memory([]),
	(atom(Size)->size(NSize,Size);	\+(atom(Size))->NSize=_),
	cell_to_coords(Cell,I,J), JC is -(J,1),
	findall(X,integer_bound(0,X, JC),LCells)		,
	get_memory(Shapes),
	forall(member(Col,LCells),
			(
				coords_to_cell(Cell2,I,Col),
				catch(_,(member([Color,Shape,NSize,Cell2],Shapes) -> set_temp_memory([[ColorA,ShapeA,SizeA,Cell]])),_)
			)	
		),set_truth_value.



%%%		Retorna las figuras que comple las condiciones que estan a la derecha de la figura indicada
leftOf([ColorAI,ShapeAI,SizeAI,CellAI],[ColorBI,ShapeBI,SizeBI,CellBI]):-
	cell_to_internal([ColorAF,ShapeAF,SizeAF,CellAF],[ColorAI,ShapeAI,SizeAI,CellAI]),cell_to_internal([ColorBF,ShapeBF,SizeBF,CellBF],[ColorBI,ShapeBI,SizeBI,CellBI]),
	set_temp_memory([]),
	cell_to_coords(CellAF,I,J), JC is +(J,1),
	findall(X,integer_bound(JC,X, 9),RCells),
	get_memory(Shapes),
	forall(member(Col,RCells),
			(
				coords_to_cell(Cell2,I,Col), 
				member([_,_,_,Cell2],Shapes,D),member(Shape,Shapes,D),
				Shape = [ColorBF,ShapeBF,SizeBF,CellBF] ->set_temp_memory([[ColorAF,ShapeAF,SizeAF,CellAF]]);!			
				
		)	
		),set_truth_value.

leftOf(Shape_,Filter):-
	arrange(Filter,[Color,Shape,Size]),
	cell_to_internal([ColorA,ShapeA,SizeA,Cell],Shape_),
	set_temp_memory([]),
	(atom(Size)->size(NSize,Size);	\+(atom(Size))->NSize=_),
	cell_to_coords(Cell,I,J), JC is +(J,1),
	findall(X,integer_bound(JC,X, 9),RCells),
	get_memory(Shapes),
	forall(member(Col,RCells),
			(
				coords_to_cell(Cell2,I,Col),
				catch(_,(member([Color,Shape,NSize,Cell2],Shapes) -> set_temp_memory([[ColorA,ShapeA,SizeA,Cell]])),_)
			)	
		),set_truth_value.




	
%%%		Retorna las figuras que comple las condiciones que estan abajo de la figura indicada
topOf([ColorAI,ShapeAI,SizeAI,CellAI],[ColorBI,ShapeBI,SizeBI,CellBI]):-
	cell_to_internal([ColorAF,ShapeAF,SizeAF,CellAF],[ColorAI,ShapeAI,SizeAI,CellAI]),cell_to_internal([ColorBF,ShapeBF,SizeBF,CellBF],[ColorBI,ShapeBI,SizeBI,CellBI]),
	set_temp_memory([]),
	cell_to_coords(CellAF,I,J), IC is +(I,1),
	findall(X,integer_bound(IC,X, 9),LCells),
	get_memory(Shapes),
	forall(member(Row,LCells),
			(
				coords_to_cell(Cell2,Row,J), 
				member([_,_,_,Cell2],Shapes,D),member(Shape,Shapes,D),
				Shape = [ColorBF,ShapeBF,SizeBF,CellBF] ->set_temp_memory([[ColorAF,ShapeAF,SizeAF,CellAF]]);!			
				
		)	
		),set_truth_value.

topOf(Shape_,Filter):-
	arrange(Filter,[Color,Shape,Size]),
	cell_to_internal([ColorA,ShapeA,SizeA,Cell],Shape_),
	set_temp_memory([]),
	(atom(Size)->size(NSize,Size);	\+(atom(Size))->NSize=_),
	cell_to_coords(Cell,I,J), IC is +(I,1),
	findall(X,integer_bound(IC,X, 9),LCells),
	get_memory(Shapes),
	
	forall(member(Row,LCells),
			(
				coords_to_cell(Cell2,Row,J),
				catch(_,(member([Color,Shape,NSize,Cell2],Shapes) -> set_temp_memory([[ColorA,ShapeA,SizeA,Cell]])),_)
						
			)
	
		),set_truth_value.


%%%		Retorna las figuras que comple las condiciones que estan arriba de la figura indicada
bottomOf([ColorAI,ShapeAI,SizeAI,CellAI],[ColorBI,ShapeBI,SizeBI,CellBI]):-
	cell_to_internal([ColorAF,ShapeAF,SizeAF,CellAF],[ColorAI,ShapeAI,SizeAI,CellAI]),cell_to_internal([ColorBF,ShapeBF,SizeBF,CellBF],[ColorBI,ShapeBI,SizeBI,CellBI]),
	set_temp_memory([]),
	cell_to_coords(CellAF,I,J), IC is -(I,1),
	findall(X,integer_bound(0,X, IC),LCells),
	get_memory(Shapes),
	forall(member(Row,LCells),
			(
				coords_to_cell(Cell2,Row,J), 
				member([_,_,_,Cell2],Shapes,D),member(Shape,Shapes,D),
				Shape = [ColorBF,ShapeBF,SizeBF,CellBF] ->set_temp_memory([[ColorAF,ShapeAF,SizeAF,CellAF]]);!			
				
		)	
		),set_truth_value.

bottomOf(Shape_,Filter):-
	arrange(Filter,[Color,Shape,Size]),
	cell_to_internal([ColorA,ShapeA,SizeA,Cell],Shape_),
	set_temp_memory([]),
	(atom(Size)->size(NSize,Size);	\+(atom(Size))->NSize=_),
	cell_to_coords(Cell,I,J), IC is -(I,1),
	findall(X,integer_bound(0,X, IC),LCells),
	get_memory(Shapes),
	forall(member(Row,LCells),
			(
				coords_to_cell(Cell2,Row,J),
				catch(_,(member([Color,Shape,NSize,Cell2],Shapes) -> set_temp_memory([[ColorA,ShapeA,SizeA,Cell]])),_)
			)	
		),set_truth_value.

%%%		Devuelve la memoria temporal/resultados
get_temp_memory(MShapes):- 
		wtext((board,5001),LisTStr0 ),cade_dato(LisTStr0 ,TShapes),
		wtext((board,6001),`[]`),
		forall(member([Color,Shape,SSize,(Col,Row)],TShapes),
				(
					RRow is -(Row,1),
					RCol is -(Col,1),
					coords_to_cell(Cell,RRow,RCol),size(Size,SSize),
					wtext((board,6001),LisTStr1 ),cade_dato(LisTStr1 ,Temp),
					append(Temp,[[Color,Shape,Size,Cell]],NTemp),
					write(NTemp) ~> String,	wtext((board,6001),String)				
				)
				),
		wtext((board,6001),LisTStr ),cade_dato(LisTStr ,MShapes).

%%%		Cambiar la memoria temporal/resultados
set_temp_memory(MShapes):-
	wtext((board,5001),`[]`),
	forall(member([Color,Shape,Size,Cell],MShapes),
			(	
				cell_to_coords(Cell,Row,Col),size(Size,SSize),
				RRow is +(Row,1),
				RCol is +(Col,1),
				wtext((board,5001),LisTStr0 ),cade_dato(LisTStr0 ,Temp),
				append(Temp,[[Color,Shape,SSize,(RCol ,RRow)]],NTemp),
				write(NTemp) ~> String,	wtext((board,5001),String)

			)
		), wtext((board,5001),L ),cade_dato(L ,S), sort(S,T,[4]),write(T) ~> Sorted,wtext((board,5001),Sorted ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

				%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
				%%%		Creacion de figuras NO resaltadas		%%%
				%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

triangle(Size,N,Color,CellSize):-
	gfx_paint( (board,N)),
	     T1_1 is +(12, *(-5 ,Size) ),
		T1_2 is +(-(CellSize,15), *( 5 ,Size) ),
		T2_1 is -(/(CellSize,2),1) ,
		T2_2 is +(11, *(-4 ,Size) ),
		T3 is +(-(CellSize,15), *( 5 ,Size) ),
		gfx((brush = Color -> polygon( T1_1, T1_2, T2_1, T2_2, T3,T3) ) ),
	 gfx_end( (board,N) ).


square(Size,N,Color,CellSize):-
	gfx_paint( (board,N)),
	  	C1 is +(13, *(-5, Size) ),
		C2 is +(-(CellSize,15), *( 5 ,Size) ),
		gfx( (brush = Color -> rectangle( C1, C1, C2, C2 ) )),  
	gfx_end( (board,N) ).


circle(Size,N,Color,CellSize):-
	gfx_paint( (board,N)),
		E1 is +(13,*(-5, Size) ),
		E2 is +(-(CellSize,15),*( 5, Size) ),
		gfx( (brush = Color -> ellipse( E1, E1, E2, E2 )) ),	    
	gfx_end( (board,N) ).


			%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
			%%%		Creacion de figuras resaltadas		%%%
			%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

triangle(Size,N,Color,CellSize,_):-
	gfx_paint( (board,N)),
		gfx(( brush = pink -> rectangle(-1,-1,41,41))),
	      T1_1 is +(12, *(-5 ,Size) ),
		T1_2 is +(-(CellSize,15), *( 5 ,Size) ),
		T2_1 is -(/(CellSize,2),1) ,
		T2_2 is +(11, *(-4 ,Size) ),
		T3 is +(-(CellSize,15), *( 5 ,Size) ),
		gfx((brush = Color -> polygon( T1_1, T1_2, T2_1, T2_2, T3,T3) ) ),
	 gfx_end( (board,N) ).


square(Size,N,Color,CellSize,_):-
	gfx_paint( (board,N)),
		gfx(( brush = pink -> rectangle(-1,-1,41,41))),
		C1 is +(13, *(-5, Size) ),
		C2 is +(-(CellSize,15), *( 5 ,Size) ),
		gfx( (brush = Color -> rectangle( C1, C1, C2, C2 ) )),  
	gfx_end( (board,N) ).


circle(Size,N,Color,CellSize,_):-
	gfx_paint( (board,N)),
		gfx(( brush = pink -> rectangle(-1,-1,41,41))),
		E1 is +(13,*(-5, Size) ),
		E2 is +(-(CellSize,15),*( 5, Size) ),
		gfx( (brush = Color -> ellipse( E1, E1, E2, E2 )) ),	    
	gfx_end( (board,N) ).

			%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
			%%%		Creacion de figuras erroneas			%%%
			%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

triangle(Size,N,Color,CellSize,_,_):-
	gfx_paint( (board,N)),
		gfx(( brush = pinkE -> rectangle(-1,-1,41,41))),
	      T1_1 is +(12, *(-5 ,Size) ),
		T1_2 is +(-(CellSize,15), *( 5 ,Size) ),
		T2_1 is -(/(CellSize,2),1) ,
		T2_2 is +(11, *(-4 ,Size) ),
		T3 is +(-(CellSize,15), *( 5 ,Size) ),
		gfx((brush = Color -> polygon( T1_1, T1_2, T2_1, T2_2, T3,T3) ) ),
	 gfx_end( (board,N) ).


square(Size,N,Color,CellSize,_,_):-
	gfx_paint( (board,N)),
		gfx(( brush = pinkE -> rectangle(-1,-1,41,41))),
		C1 is +(13, *(-5, Size) ),
		C2 is +(-(CellSize,15), *( 5 ,Size) ),
		gfx( (brush = Color -> rectangle( C1, C1, C2, C2 ) )),  
	gfx_end( (board,N) ).


circle(Size,N,Color,CellSize,_,_):-
	gfx_paint( (board,N)),
		gfx(( brush = pinkE -> rectangle(-1,-1,41,41))),
		E1 is +(13,*(-5, Size) ),
		E2 is +(-(CellSize,15),*( 5, Size) ),
		gfx( (brush = Color -> ellipse( E1, E1, E2, E2 )) ),	    
	gfx_end( (board,N) ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

				%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
				%%%		Creacíon aleatoria de figuras, tamaños y colores		%%%
				%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
selec(Ls,Elem):-
	length(Ls,N), 
	D is int(rand(N))+1,
	member(Elem,Ls,D).
 
tomaRand(0, Ls,[]):-!.
tomaRand(N, Ls,[Elem|Res]):-
	selec(Ls,Elem),M is N-1,
	tomaRand(M,Ls,Res),!.
  

tomaRandID(0, Ls,[]):-!.
tomaRandID(N, Ls,[Elem|Res]):-
	selec(Ls,Elem),
	remove(Elem,Ls,Ls1),M is N-1,
	tomaRandID(M,Ls1,Res),!.


idents(LS):-findall(N, integer_bound(0,N,99),LS).
  
  
mezcla([],[],[],[],[]):-!.  
mezcla([Color|L1],[Figura|L2],[Tamaño|L3],[N|L4],[[Color,Figura,Tamaño,N]|Rs]):- mezcla(L1,L2,L3,L4,Rs).
 

entraF(Rs):-  
	wtext((board,8002),Text),
	cade_dato(Text,Cant),
	idents(IDs),
	tomaRand(Cant,[red,green,blue,yellow,cyan],Cs), 
	tomaRand(Cant,[triangle,circle,square],Fs),
	tomaRand(Cant,[0,1,2],Ts),
	tomaRandID(Cant,IDs,Ns),
	mezcla(Cs,Fs,Ts,Ns,Rs).

%board_handler((board,1000),msg_paint,_,_):- pinte.

pinte:-
	get_memory(List0),
	forall( member([Color,Figura,Tamaño,N],List0) , Figura(Tamaño,N,Color,40 ) ).


pintar:-entraF(List),set_memory(List),pinte.


cade_dato(Str,Dat):- 
	string_chars( Str, Ch),
	append(Ch,[46,32],T),
	string_chars( Str2,T),
	read(Dat)<~Str2.


inte(X,X,[]):-!.
inte(X,Y,[Z|Rs]):-X<Y,Z is X+1,inte(Z,Y,Rs).


integer_bound(X,Y,Z):-inte(X-1,Z,Ls),member(Y,Ls).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%





%%%		Convierte de numero de celda a coordenas (X,Y) y viceversa
coords_to_cell(Cell,Row,Col):-	Cell is +(Col,*(Row,10)).
cell_to_coords(Cell,Row,Col):-	Row is //(Cell,10),Col is -(Cell,*(Row,10)).


%%%		Devuelve la memoria del tablero
get_memory(MShapes):- 
		wtext((board,5000),LisTStr0 ),cade_dato(LisTStr0 ,TShapes),
		wtext((board,6000),`[]`),
		forall(member([Color,Shape,SSize,(Col,Row)],TShapes),
				(
					RRow is -(Row,1),
					RCol is -(Col,1),
					coords_to_cell(Cell,RRow,RCol),size(Size,SSize),
					wtext((board,6000),LisTStr1 ),cade_dato(LisTStr1 ,Temp),
					append(Temp,[[Color,Shape,Size,Cell]],NTemp),
					write(NTemp) ~> String,	wtext((board,6000),String)				
				)
				),
		wtext((board,6000),LisTStr ),cade_dato(LisTStr ,MShapes).

%%%		Cambiar la memoria del tablero a 'MShapes'
set_memory(MShapes):-
	wtext((board,5000),`[]`),
	forall(member([Color,Shape,Size,Cell],MShapes),
			(	
				cell_to_coords(Cell,Row,Col),size(Size,SSize),
				RRow is +(Row,1),
				RCol is +(Col,1),
				wtext((board,5000),LisTStr0 ),cade_dato(LisTStr0 ,Temp),
				append(Temp,[[Color,Shape,SSize,(RCol ,RRow)]],NTemp),
				write(NTemp) ~> String,	wtext((board,5000),String)

			)
		), wtext((board,5000),L ),cade_dato(L ,S), sort(S,T,[4]),write(T) ~> Sorted,wtext((board,5000),Sorted ) .

%%% 		get y set del texto de la figura que se va a insertar
get_preview_shape(Size,Shape,Color):- 	wtext((board,8003),TShape), cade_dato(TShape,[SSize,Color,Shape]),size(Size,SSize).
set_preview_shape([Size,Color,Shape]):- 	size(Size,SSize),	write([SSize,Color,Shape]) ~> Fig, wtext((board,8003),Fig).

%%%		Crear un nuevo tablero aleatorio con el numero de figuras dadas
board_handler((board,1001),msg_button,_,_):-  
	catch(_,create_new_board,_).

create_new_board:-
	msgbox( `New board`, `Clear board and start a new one?`, 36, Ans ),
		(  Ans = 6
			-> 
			wtext((board,8002),Text),
			cade_dato(Text,Cant),
			(	
				integer_bound(0,Cant,100)->	(
					forall(integer_bound(0,N,99),(refresh_cell(N))),
					pintar,
					wbtnsel( (board,3003),State),
     		   			State = 1 ->(
							wtext((board,8000),`0`),
							set_number_shapes,
							get_memory(Mem),write(Mem)~>R,
							wtext((board,7000),R)			
				     			);!
					);
				\+(integer_bound(0,Cant,100))->(msgbox( `` , `Number of shapes must be between 1 and 100`, 64, _ ))
			);fail
		).

%%%		Evalua lo ingresado en el recuadro de texto 
board_handler((board,1002),msg_button,_,_):-
	catch(A,(evaluate,
	wbtnsel((board,3003),Status),
	Status = 1 ->(
				wtext((board,8004),StringI),
				number_string(NShapesI,StringI),
				(NShapesI > 0 -> (shapes_left,add_step, add_list);
				NShapesI = 0 -> msgbox(`Error`, `There is no shapes left`,40,_);
				!)
			  )),_), wenable((board,8001),1),
((A =\= 22,A > 0) ->(set_error,error(A,String),msgbox( `Input error` , String, 64, _ ));set_truth_value).

shapes_left:- 
	wtext((board,8004),StringI),
	number_string(NShapesI,StringI),
	get_memory(MemI),
	get_temp_memory(TmemI),
	difference(MemI,TmemI,MemF),
	set_memory(MemF),
	set_number_shapes,
	wtext((board,8004),StringF),
	number_string(NShapesF,StringF),
	NShapesDel is -(NShapesI,NShapesF),
	number_string(NShapesDel,SShapesDel),
	cat([SShapesDel,` deleted shape(s)`],Message,_),
	msgbox(``,Message,0,_).

add_step:-
	
	wtext((board,8000),StringI), 
	number_string(Cant,StringI),
	NSteps is +(Cant,1),
	number_string(NSteps,FSteps),
	wtext((board,8000),FSteps),
	wtext((board,8004),SShapes),
	number_string(NShapesI,SShapes),
	NShapesI = 0 -> msgbox(`Cleared board`,`Congrats! All shapes eliminated.`,0,_);! .

add_list:-
	wtext((board,8001),Text),
	wlstadd((list_dialog,4000),0,Text,0),
	wtext((list_dialog,9000),Text).


evaluate:-
	wtext((board,6101),`[]`),
	wshow((board,11000),0),
	set_temp_memory([]),
	refresh_highlight,
	wtext((board,8001),Text),
	string_replace_all( Text, `|`, `\`, A),
	string_replace_all( A, `==`, `$`, B),
	string_replace_all(B, ` is(`, ` ¿(`,C),
	string_replace_all(C, ` is (`, ` ¿(`,D),
	cade_dato(D,Oper),
	call(Oper),
	wshow((board,11000),1).
 
%%%		Resalta las figuras que comuplen con la condición
refresh_highlight:-
	get_temp_memory(TMemory),
	TMemory == [] -> (
					get_memory(Memory),
					forall(member([_,_,_,Cell],Memory),
							(
								refresh_cell(Cell)
							)
						)
				);(
					forall(member([_,_,_,Cell],TMemory),
							(	
								refresh_cell(Cell)
							)
						)
				).

%%%		Abrir dialogo para guardar el tablero en un archivo
board_handler((board,1030),msg_button,_,_):- 
	get_memory(TShapes),
	savbox( `Save As...`,[(`Board file (*.br)`,`*.br`)], ``, `br`,[File]),
	fcreate( File, File, -1, 0, 0 ),output( File ), write( TShapes ), nl, output( 0 ),fclose(File).
	   

%%%     Abrir dialogo para apertura de archivo     
board_handler((board,1000),msg_button,_,_):-
    opnbox( `Open board`,[(`Board file (*.br)`,`*.br`)], ``, `br`, Files),
    integer_bound(0,M,99), forall(integer_bound(0,N,99),(refresh_cell(N))),
    forall(member(X,Files),
            (
                see(X),
                read_file(R),
                cade_dato(R,Shapes),
                set_memory(Shapes),
                seen,
		    wbtnsel( (board,3003),State),
     		    State = 1 ->(
					wtext((board,8000),`0`),
					set_number_shapes,wtext((board,7000),R)			
				     );!
            )
        ).
 
%%%     Lectura del archivo abierto
read_file(Record):-
    fread(s,0,-1,Line ),
    write(Line)~>Record.

%%%		Reemplazar en un texto (OldString) tadas las coincidencias de 'From' a 'To'
string_replace_all( OldString, From, To, NewString ) :-
   (  repeat,
      (  find( From, 2, Find ),
         Find = ``,
         !
      ;  write( To ),
         fail
      )
   ) <~ OldString ~> NewString.

%%%		Insertar la figura en el texto de entrada al hacer doble click
board_handler((board,N), msg_leftdouble,_,_):-
	N<100 ->(
			get_memory(Shapes),
			member([_,_,_,N],Shapes,P),
			member(Shape,Shapes,P),
			cell_to_external(Shape, [Color,Shape2,Size,(X,Y)]),
			write([Color,Shape2,Size,(X,Y)])~>Fig,
			addSymbol(Fig)
		  ).

%%%		Dibuja y colorea los botones y figuras que no son del tablero
board_handler((board,N),msg_paint,_,_):-   
	N=20000->conf(red, N);
	N=20001->conf(blue, N);	
	N=20002->conf(yellow, N); 
	N=20003->conf(cyan, N);
	N=20004->conf(green, N);
	N=10000->square(2,N,black,30);
	N=10001->circle(2,N,black,30);
	N=10002->triangle(2,N,black,30);
	N=10003->draw_preview_shape;	
	N=10004->conf(red, N);
	N=10005->conf(blue, N);	
	N=10006->conf(yellow, N); 
	N=10007->conf(cyan, N);
	N=10008->conf(green, N).	

%%%		Cambiar el tamaño y color de la figura a insertar 
board_handler((board,N),msg_leftdown,_,_):-
	(N=20000->change_color(red);
	N=20001->change_color(blue);
	N=20002->change_color(yellow); 
	N=20003->change_color(cyan);
	N=20004->change_color(green);
	N=10000->change_shape(square);
	N=10001->change_shape(circle);
	N=10002->change_shape(triangle);
	N=10003->change_size),
	refresh_cell(10003).

%%%		Actividad del Modo juego
board_handler( (board,3003), msg_button, _,_):-
	wbtnsel( (board,3003),State),
/*Unchecked*/	(State = 0 -> 	(
						set_temp_memory([]),
						wtext((board,8000),``),
						wtext((board,8004),``),
						wenable((board,1032),0),
						wenable((board,5000),1),
						wenable((board,6000),1),
						wenable((board,5001),1),
						wenable((board,6001),1),
						wenable((board,1030),1),
						wclose(list_dialog),
						wtext((board,7000),Mem),cade_dato(Mem,CadeDato),set_memory(CadeDato),
						forall(integer_bound(0,N,99),(refresh_cell(N))));
/*Checked*/		State = 1 -> 	(
						set_temp_memory([]),
						wtext((board,8000),`0`),
						set_number_shapes,
						wenable((board,1032),1),
						wenable((board,5000),0),
						wenable((board,6000),0),
						wenable((board,5001),0),
						wenable((board,6001),0),
						wenable((board,1030),0),
						show_list,
						get_memory(MemA), write(MemA)~> SMemA,wtext((board,7000),SMemA)
						);!).

board_handler( (board,1032), msg_button, _,_):-
	
	wtext((board,7000),TMem),
	cade_dato(TMem,CTmem),
	set_memory(CTmem),
	forall(integer_bound(0,N,99),(refresh_cell(N))),
	wtext((board,8000),`0`),
	set_number_shapes,
	wclose(list_dialog),
	show_list.

show_list:-
	list_dialog,
	window_handler(list_dialog,list_handler),
	show_dialog(list_dialog).

%%%		Registro del click derecho en el tablero para insertar o borrar figura
board_handler( (board,N), msg_rightdown,(X,Y), _ ) :-
	
	N<100	->	(
				wbtnsel( (board,3003),State),
				State = 0 -> (
							popup_menu( (board,N), menu, X, Y )
						 );!
			).



%%%		Obtiene la cantidad de figuras que hay en el tablero y las muestra .
set_number_shapes:-
	get_memory(Mem), len(Mem,NShapes),write(NShapes)~>String,wtext((board,8004),String).


%%%		Acciones de las opciones de menu
board_handler( (board,N), msg_menu, MenuItem, _ ):-
	(
		MenuItem = 1000 -> insert_shape(N);
		MenuItem = 1001 -> delete_shape(N)
	),
	refresh_cell(N).

board_handler((board,8001),msg_rightdown,(X,Y),_):-
	popup_menu((board,8001),tools_menu,X,Y).

board_handler( (board,8001), msg_menu, MenuItem, _ ):-
		MenuItem = 1002 -> wedtclp((board,8001),1);
		MenuItem = 1003 -> wedtclp((board,8001),2);
		MenuItem = 1004 -> wedtclp((board,8001),3);
		MenuItem = 1005 -> wedtclp((board,8001),4);
		MenuItem = 1006 ->(wtext((board,8001),Text),len(Text,Len), wedtsel( (board,8001), 0, Len)) ;!.

%%%		Repinta las figuras del tablero
board_handler((board,N),msg_paint,_,_):- 	N<100 -> redraw(N).

%%%		Dibuja la figura que se insertará
draw_preview_shape:-
	get_preview_shape(Size,Shape,Color),
	Shape(Size,10003,Color,50).

%%%		Pinta la figura que esta en la posición 'Cell'
redraw(Cell):-
	get_memory(Shapes),
	get_temp_memory(TShapes),
	wtext((board,6101),TxtError),cade_dato(TxtError,Error),
	
	member([_,_,_,Cell],Shapes,P),
	member([Color,Shape,Size,Cell],Shapes,P),
	(member([_,_,_,Cell],TShapes)->Shape(Size,Cell,Color,40,_);
	member([_,_,_,Cell],Error)->Shape(Size,Cell,Color,40,_,_);Shape(Size,Cell,Color,40)).	
	
%%%		Borra la figura que esta en la posición 'Cell'
delete_shape(N):-
	get_memory(IShapes),
	remove([_,_,_,N],IShapes,FShapes),
	set_memory(FShapes), 
	refresh_cell(N),
	get_temp_memory(TIShapes),
	remove([_,_,_,N],TIShapes,TFShapes),
	set_temp_memory(TFShapes).

%%%		Inserta la figura en la posición 'Cell', si ya esta ocupada, no hace nada
insert_shape(Cell):-
	get_preview_shape(Size,Shape,Color),
	get_memory(IShapes),
	Sha = [[Color,Shape,Size,Cell]],
	\+( member([_,_,_,Cell],IShapes) ) ->( append(IShapes,Sha,FShapes),set_memory(FShapes) ).

%%%		Cambia el poligono(Cuadrado, circulo o triangulo) de la figura que se va a insertar
change_shape(Shape):-
	get_preview_shape(Size,_,Color),
	set_preview_shape([Size,Color,Shape]).

%%%		Cambia el color de la figura que se insertará
change_color(Color):-
	get_preview_shape(Size,Shape,_),
	set_preview_shape([Size,Color,Shape]).

%%%		Cambia el tamaño de la figura que se insertará
change_size:-
	get_preview_shape(Size,Shape,Color),
	(
		Size =:=2 -> NSize is 0;
		Size =\= 2 ->NSize is +(Size,1)
	),	
	set_preview_shape([NSize,Color,Shape]).

%%%		Pinta los recuadros de colores de color 'M'
conf(M,N):- 
	gfx_paint( (board,N)),
		gfx( (brush =M -> rectangle(-1, -1,31,31)) ),
	gfx_end( (board,N) ).

%%%		Limpiar el texto , la memoria temporal y el valor de verdad
board_handler((board,1031),msg_button,_,_):-
	
	get_memory(TShapes),
	wbtnsel( (board,3003),State),
	(State = 0 ->(
		set_temp_memory([]),
		forall( member([Color,Shape,Size,Cell],TShapes) ,
				( 
					Shape(Size,Cell,Color,40),refresh_cell(Cell)
				)
			)
		)),
		
	wtext((board,8001),``),
	wtext((board,11000),``).

refresh_cell(Cell):- wshow((board,Cell),0),wshow((board,Cell),1).

%%%		registro de la tecla enter en el cuadro de numero de figuras para comenzar un nuevo tablero
board_handler( (board,8002), msg_key, (Flag,28,13), Result ):-
	wenable((board,8002),0),
	catch(_,create_new_board,_),	
	wenable((board,8002),1).

%%%		registro de la tecla enter en el cuadro de operaciones para comenzar un nuevo tablero
board_handler( (board,8001), msg_key, (Flag,28,13), Result ):-
	wenable((board,8001),0),
	catch(A,(
			evaluate,
			wbtnsel((board,3003),Status),
			Status = 1 ->(
				wtext((board,8004),StringI),
				number_string(NShapesI,StringI),
				NShapesI = 0 -> 	msgbox(``, `There is no shapes left`,0,_);
							(shapes_left,add_step, add_list)
			  )
		),B), wenable((board,8001),1),
	((A =\= 22,A > 0) ->(set_error,error(A,String),msgbox( `Input error` , String, 64, _ ));set_truth_value).

error(0,``).
error(-1,``).
error(20,`Check your sintax (parenthesis or sintax)`).
error(21,`Check your sintax`).
error(23, `Check your variable's ussage`).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%         Inserta los simbolos y texto al recuadro         %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
board_handler((board,1003),msg_button,_,_):- addSymbol(`∧ `).
board_handler((board,1004),msg_button,_,_):- addSymbol(`∨ `).
board_handler((board,1005),msg_button,_,_):- addSymbol(`∀(x: [Color,Shape,Size,((I,J),Ecuation)] | _ : _ ) `).
board_handler((board,1006),msg_button,_,_):- addSymbol(`∃(x: [Color,Shape,Size,((I,J),Ecuation)] | _ : _ ) `).
board_handler((board,1007),msg_button,_,_):- addSymbol(`lessThan([color,shape,size,(i,j)] ,_) `).
board_handler((board,1008),msg_button,_,_):- addSymbol(`greaterThan([color,shape,size,(i,j)] ,_)  `).
board_handler((board,1010),msg_button,_,_):- addSymbol(`atLeast([color,shape,size,(i,j)] ,_) `).
board_handler((board,1011),msg_button,_,_):- addSymbol(`atMost([color,shape,size,(i,j)] ,_) `).
board_handler((board,1012),msg_button,_,_):- addSymbol(`( ) `).
board_handler((board,1014),msg_button,_,_):- addSymbol(`equal([color,shape,size,(i,j)],[color,shape,size,(i,j)]) `).
board_handler((board,1015),msg_button,_,_):- addSymbol(`different([color,shape,size,(i,j)],[color,shape,size,(i,j)]) `).
board_handler((board,1016),msg_button,_,_):- addSymbol(`⇒ `).
board_handler((board,1018),msg_button,_,_):- addSymbol(`¬ `).
board_handler((board,1020),msg_button,_,_):- addSymbol(`triangle `).
board_handler((board,1021),msg_button,_,_):- addSymbol(`circle `).
board_handler((board,1022),msg_button,_,_):- addSymbol(`square `).
board_handler((board,1023),msg_button,_,_):- addSymbol(`big `).
board_handler((board,1024),msg_button,_,_):- addSymbol(`medium `).
board_handler((board,1025),msg_button,_,_):- addSymbol(`small `).
board_handler((board,1026),msg_button,_,_):- addSymbol(`topOf( [color,shape,size,(i,j)] , [Color,Shape,Size] )`).
board_handler((board,1027),msg_button,_,_):- addSymbol(`bottomOf( [color,shape,size,(i,j)] , [Color,Shape,Size] ) `).
board_handler((board,1028),msg_button,_,_):- addSymbol(`leftOf( [color,shape,size,(i,j)] , [Color,Shape,Size] ) `).
board_handler((board,1029),msg_button,_,_):- addSymbol(`rightOf( [color,shape,size,(i,j)] , [Color,Shape,Size] )`).
board_handler((board,10004),msg_leftdown,_,_):- addSymbol(`red `).
board_handler((board,10005),msg_leftdown,_,_):- addSymbol(`blue `).
board_handler((board,10006),msg_leftdown,_,_):- addSymbol(`yellow `).
board_handler((board,10007),msg_leftdown,_,_):- addSymbol(`cyan `).
board_handler((board,10008),msg_leftdown,_,_):- addSymbol(`green `).

board_handler((board,1005),msg_rightdown,_,_):- addSymbol(`∀`).
board_handler((board,1006),msg_rightdown,_,_):- addSymbol(`∃`).
board_handler((board,1026),msg_rightdown,_,_):- addSymbol(`topOf`).
board_handler((board,1027),msg_rightdown,_,_):- addSymbol(`bottomOf`).
board_handler((board,1028),msg_rightdown,_,_):- addSymbol(`leftOf`).
board_handler((board,1029),msg_rightdown,_,_):- addSymbol(`rightOf`).
board_handler((board,1007),msg_rightdown,_,_):- addSymbol(`lessThan`).
board_handler((board,1008),msg_rightdown,_,_):- addSymbol(`greaterThan`).
board_handler((board,1010),msg_rightdown,_,_):- addSymbol(`atLeast`).
board_handler((board,1011),msg_rightdown,_,_):- addSymbol(`atMost`).
board_handler((board,1014),msg_rightdown,_,_):- addSymbol(`equal`).
board_handler((board,1015),msg_rightdown,_,_):- addSymbol(`different`).


%%%		Inserta texto al recuadro
addSymbol(Symbol):- 
	wedtsel((board,8001),IS,FS), 
	wedttxt((board,8001),Text),
	Text = `` ->( 
				concat(Text,Symbol,FText), 	
				wedttxt((board,8001),FText)
			);
			wedttxt((board,8001),Symbol).

concat(First,Second,Result):-	cat([First,Second],Result,_).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%		Creación de interfaz		%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

create_board :- 
   _S1 = [ws_caption,ws_minimizebox,ws_sysmenu,dlg_ownedbyprolog],
   _S2 = [ws_child,ws_border,ws_visible],
   _S3 = [ws_child,ws_tabstop,ws_visible,bs_pushbutton,bs_text,bs_center,bs_vcenter],
   _S4 = [ws_child,bs_groupbox,ws_visible,bs_left],
   _S5 = [ws_child,ws_border,ws_tabstop,ws_visible,ws_vscroll,es_left,es_multiline,es_autovscroll],
   _S6 = [ws_child,ws_border,ws_tabstop,ws_visible,es_left,es_multiline,es_autohscroll,es_autovscroll],
   _S7 = [ws_child,ws_border,ws_tabstop,es_left,es_multiline,es_autohscroll,es_autovscroll],
   _S8 = [ws_child,ws_visible,ss_left],
   _S9 = [ws_child,ws_border,ws_disabled,ws_tabstop,ws_visible,es_center,es_multiline,es_autohscroll,es_autovscroll],
   _S10 = [ws_child,ws_visible,ws_tabstop],
   _S11 = [ws_child,ws_disabled,ws_visible,es_center],
   _S12 = [ws_child,ws_visible,ss_left,ss_centerimage],
   _S13 = [ws_child,ws_tabstop,ws_visible,bs_autocheckbox,bs_text,bs_left,bs_vcenter],
   _S14 = [ws_child,ws_border,ws_disabled,ws_tabstop,ws_visible,es_left,es_multiline,es_autohscroll,es_autovscroll],
   _S15 = [ws_child,ws_disabled,ws_tabstop,ws_visible,bs_pushbutton,bs_text,bs_center,bs_vcenter],
   wdcreate(  board,        `Board`,                              614, 140, 1066, 749, _S1  ),
   wccreate( (board,0),     grafix,   `Grafix1`,                   38, 108,   40,  40, _S2  ),
   wccreate( (board,1),     grafix,   `Grafix1`,                   78, 108,   40,  40, _S2  ),
   wccreate( (board,2),     grafix,   `Grafix1`,                  118, 108,   40,  40, _S2  ),
   wccreate( (board,3),     grafix,   `Grafix1`,                  158, 108,   40,  40, _S2  ),
   wccreate( (board,4),     grafix,   `Grafix1`,                  198, 108,   40,  40, _S2  ),
   wccreate( (board,5),     grafix,   `Grafix1`,                  238, 108,   40,  40, _S2  ),
   wccreate( (board,6),     grafix,   `Grafix1`,                  278, 108,   40,  40, _S2  ),
   wccreate( (board,7),     grafix,   `Grafix1`,                  318, 108,   40,  40, _S2  ),
   wccreate( (board,8),     grafix,   `Grafix1`,                  358, 108,   40,  40, _S2  ),
   wccreate( (board,9),     grafix,   `Grafix1`,                  398, 108,   40,  40, _S2  ),
   wccreate( (board,10),    grafix,   `Grafix1`,                   38, 148,   40,  40, _S2  ),
   wccreate( (board,11),    grafix,   `Grafix1`,                   78, 148,   40,  40, _S2  ),
   wccreate( (board,12),    grafix,   `Grafix1`,                  118, 148,   40,  40, _S2  ),
   wccreate( (board,13),    grafix,   `Grafix1`,                  158, 148,   40,  40, _S2  ),
   wccreate( (board,14),    grafix,   `Grafix1`,                  198, 148,   40,  40, _S2  ),
   wccreate( (board,15),    grafix,   `Grafix1`,                  238, 148,   40,  40, _S2  ),
   wccreate( (board,16),    grafix,   `Grafix1`,                  278, 148,   40,  40, _S2  ),
   wccreate( (board,17),    grafix,   `Grafix1`,                  318, 148,   40,  40, _S2  ),
   wccreate( (board,18),    grafix,   `Grafix1`,                  358, 148,   40,  40, _S2  ),
   wccreate( (board,19),    grafix,   `Grafix1`,                  398, 148,   40,  40, _S2  ),
   wccreate( (board,20),    grafix,   `Grafix1`,                   38, 188,   40,  40, _S2  ),
   wccreate( (board,21),    grafix,   `Grafix1`,                   78, 188,   40,  40, _S2  ),
   wccreate( (board,22),    grafix,   `Grafix1`,                  118, 188,   40,  40, _S2  ),
   wccreate( (board,23),    grafix,   `Grafix1`,                  158, 188,   40,  40, _S2  ),
   wccreate( (board,24),    grafix,   `Grafix1`,                  198, 188,   40,  40, _S2  ),
   wccreate( (board,25),    grafix,   `Grafix1`,                  238, 188,   40,  40, _S2  ),
   wccreate( (board,26),    grafix,   `Grafix1`,                  278, 188,   40,  40, _S2  ),
   wccreate( (board,27),    grafix,   `Grafix1`,                  318, 188,   40,  40, _S2  ),
   wccreate( (board,28),    grafix,   `Grafix1`,                  358, 188,   40,  40, _S2  ),
   wccreate( (board,29),    grafix,   `Grafix1`,                  398, 188,   40,  40, _S2  ),
   wccreate( (board,30),    grafix,   `Grafix1`,                   38, 228,   40,  40, _S2  ),
   wccreate( (board,31),    grafix,   `Grafix1`,                   78, 228,   40,  40, _S2  ),
   wccreate( (board,32),    grafix,   `Grafix1`,                  118, 228,   40,  40, _S2  ),
   wccreate( (board,33),    grafix,   `Grafix1`,                  158, 228,   40,  40, _S2  ),
   wccreate( (board,34),    grafix,   `Grafix1`,                  198, 228,   40,  40, _S2  ),
   wccreate( (board,35),    grafix,   `Grafix1`,                  238, 228,   40,  40, _S2  ),
   wccreate( (board,36),    grafix,   `Grafix1`,                  278, 228,   40,  40, _S2  ),
   wccreate( (board,37),    grafix,   `Grafix1`,                  318, 228,   40,  40, _S2  ),
   wccreate( (board,38),    grafix,   `Grafix1`,                  358, 228,   40,  40, _S2  ),
   wccreate( (board,39),    grafix,   `Grafix1`,                  398, 228,   40,  40, _S2  ),
   wccreate( (board,40),    grafix,   `Grafix1`,                   38, 268,   40,  40, _S2  ),
   wccreate( (board,41),    grafix,   `Grafix1`,                   78, 268,   40,  40, _S2  ),
   wccreate( (board,42),    grafix,   `Grafix1`,                  118, 268,   40,  40, _S2  ),
   wccreate( (board,43),    grafix,   `Grafix1`,                  158, 268,   40,  40, _S2  ),
   wccreate( (board,44),    grafix,   `Grafix1`,                  198, 268,   40,  40, _S2  ),
   wccreate( (board,45),    grafix,   `Grafix1`,                  238, 268,   40,  40, _S2  ),
   wccreate( (board,46),    grafix,   `Grafix1`,                  278, 268,   40,  40, _S2  ),
   wccreate( (board,47),    grafix,   `Grafix1`,                  318, 268,   40,  40, _S2  ),
   wccreate( (board,48),    grafix,   `Grafix1`,                  358, 268,   40,  40, _S2  ),
   wccreate( (board,49),    grafix,   `Grafix1`,                  398, 268,   40,  40, _S2  ),
   wccreate( (board,50),    grafix,   `Grafix1`,                   38, 308,   40,  40, _S2  ),
   wccreate( (board,51),    grafix,   `Grafix1`,                   78, 308,   40,  40, _S2  ),
   wccreate( (board,52),    grafix,   `Grafix1`,                  118, 308,   40,  40, _S2  ),
   wccreate( (board,53),    grafix,   `Grafix1`,                  158, 308,   40,  40, _S2  ),
   wccreate( (board,54),    grafix,   `Grafix1`,                  198, 308,   40,  40, _S2  ),
   wccreate( (board,55),    grafix,   `Grafix1`,                  238, 308,   40,  40, _S2  ),
   wccreate( (board,56),    grafix,   `Grafix1`,                  278, 308,   40,  40, _S2  ),
   wccreate( (board,57),    grafix,   `Grafix1`,                  318, 308,   40,  40, _S2  ),
   wccreate( (board,58),    grafix,   `Grafix1`,                  358, 308,   40,  40, _S2  ),
   wccreate( (board,59),    grafix,   `Grafix1`,                  398, 308,   40,  40, _S2  ),
   wccreate( (board,60),    grafix,   `Grafix1`,                   38, 348,   40,  40, _S2  ),
   wccreate( (board,61),    grafix,   `Grafix1`,                   78, 348,   40,  40, _S2  ),
   wccreate( (board,62),    grafix,   `Grafix1`,                  118, 348,   40,  40, _S2  ),
   wccreate( (board,63),    grafix,   `Grafix1`,                  158, 348,   40,  40, _S2  ),
   wccreate( (board,64),    grafix,   `Grafix1`,                  198, 348,   40,  40, _S2  ),
   wccreate( (board,65),    grafix,   `Grafix1`,                  238, 348,   40,  40, _S2  ),
   wccreate( (board,66),    grafix,   `Grafix1`,                  278, 348,   40,  40, _S2  ),
   wccreate( (board,67),    grafix,   `Grafix1`,                  318, 348,   40,  40, _S2  ),
   wccreate( (board,68),    grafix,   `Grafix1`,                  358, 348,   40,  40, _S2  ),
   wccreate( (board,69),    grafix,   `Grafix1`,                  398, 348,   40,  40, _S2  ),
   wccreate( (board,70),    grafix,   `Grafix1`,                   38, 388,   40,  40, _S2  ),
   wccreate( (board,71),    grafix,   `Grafix1`,                   78, 388,   40,  40, _S2  ),
   wccreate( (board,72),    grafix,   `Grafix1`,                  118, 388,   40,  40, _S2  ),
   wccreate( (board,73),    grafix,   `Grafix1`,                  158, 388,   40,  40, _S2  ),
   wccreate( (board,74),    grafix,   `Grafix1`,                  198, 388,   40,  40, _S2  ),
   wccreate( (board,75),    grafix,   `Grafix1`,                  238, 388,   40,  40, _S2  ),
   wccreate( (board,76),    grafix,   `Grafix1`,                  278, 388,   40,  40, _S2  ),
   wccreate( (board,77),    grafix,   `Grafix1`,                  318, 388,   40,  40, _S2  ),
   wccreate( (board,78),    grafix,   `Grafix1`,                  358, 388,   40,  40, _S2  ),
   wccreate( (board,79),    grafix,   `Grafix1`,                  398, 388,   40,  40, _S2  ),
   wccreate( (board,80),    grafix,   `Grafix1`,                   38, 428,   40,  40, _S2  ),
   wccreate( (board,81),    grafix,   `Grafix1`,                   78, 428,   40,  40, _S2  ),
   wccreate( (board,82),    grafix,   `Grafix1`,                  118, 428,   40,  40, _S2  ),
   wccreate( (board,83),    grafix,   `Grafix1`,                  158, 428,   40,  40, _S2  ),
   wccreate( (board,84),    grafix,   `Grafix1`,                  198, 428,   40,  40, _S2  ),
   wccreate( (board,85),    grafix,   `Grafix1`,                  238, 428,   40,  40, _S2  ),
   wccreate( (board,86),    grafix,   `Grafix1`,                  278, 428,   40,  40, _S2  ),
   wccreate( (board,87),    grafix,   `Grafix1`,                  318, 428,   40,  40, _S2  ),
   wccreate( (board,88),    grafix,   `Grafix1`,                  358, 428,   40,  40, _S2  ),
   wccreate( (board,89),    grafix,   `Grafix1`,                  398, 428,   40,  40, _S2  ),
   wccreate( (board,90),    grafix,   `Grafix1`,                   38, 468,   40,  40, _S2  ),
   wccreate( (board,91),    grafix,   `Grafix1`,                   78, 468,   40,  40, _S2  ),
   wccreate( (board,92),    grafix,   `Grafix1`,                  118, 468,   40,  40, _S2  ),
   wccreate( (board,93),    grafix,   `Grafix1`,                  158, 468,   40,  40, _S2  ),
   wccreate( (board,94),    grafix,   `Grafix1`,                  198, 468,   40,  40, _S2  ),
   wccreate( (board,95),    grafix,   `Grafix1`,                  238, 468,   40,  40, _S2  ),
   wccreate( (board,96),    grafix,   `Grafix1`,                  278, 468,   40,  40, _S2  ),
   wccreate( (board,97),    grafix,   `Grafix1`,                  318, 468,   40,  40, _S2  ),
   wccreate( (board,98),    grafix,   `Grafix1`,                  358, 468,   40,  40, _S2  ),
   wccreate( (board,99),    grafix,   `Grafix1`,                  398, 468,   40,  40, _S2  ),
   wccreate( (board,1000),  button,   `Open Board`,                38,  58,   80,  30, _S3  ),
   wccreate( (board,1001),  button,   `New board`,                138,  58,   80,  30, _S3  ),
   wccreate( (board,12000), button,   `Board`,                     28,  28,  420, 490, _S4  ),
   wccreate( (board,8001),  edit,     ``,                         520,  48,  500,  72, _S5  ),
   wccreate( (board,1002),  button,   `Enter`,                    632, 136,   88,  32, _S3  ),
   wccreate( (board,1016),  button,   `→`,                        640, 460,   30,  30, _S3  ),
   wccreate( (board,1018),  button,   `¬`,                        714, 464,   30,  30, _S3  ),
   wccreate( (board,1003),  button,   `∧`,                        590, 440,   30,  30, _S3  ),
   wccreate( (board,1004),  button,   `∨`,                        590, 480,   30,  30, _S3  ),
   wccreate( (board,1005),  button,   `∀`,                        540, 440,   30,  30, _S3  ),
   wccreate( (board,1006),  button,   ` ∃`,                       540, 480,   30,  30, _S3  ),
   wccreate( (board,1007),  button,   `<`,                        910, 440,   30,  30, _S3  ),
   wccreate( (board,1008),  button,   `>`,                        960, 440,   30,  30, _S3  ),
   wccreate( (board,1010),  button,   `≥`,                        910, 480,   30,  30, _S3  ),
   wccreate( (board,1011),  button,   `≤`,                        960, 480,   30,  30, _S3  ),
   wccreate( (board,1012),  button,   `( )`,                      786, 464,   30,  30, _S3  ),
   wccreate( (board,1014),  button,   `== `,                      860, 440,   30,  30, _S3  ),
   wccreate( (board,1015),  button,   `≠`,                        860, 480,   30,  30, _S3  ),
   wccreate( (board,12002), button,   ``,                         530, 420,  150, 100, _S4  ),
   wccreate( (board,12001), button,   ``,                         850, 420,  150, 100, _S4  ),
   wccreate( (board,5000),  edit,     `[]`,                        12, 684,  455,  25, _S6  ),
   wccreate( (board,6000),  edit,     `[]`,                        12, 684,  455,  25, _S7  ),
   wccreate( (board,6100),  edit,     `[]`,                        12, 684,  455,  25, _S7  ),
   wccreate( (board,5001),  edit,     `[]`,                       486, 684,  565,  25, _S6  ),
   wccreate( (board,6001),  edit,     `[]`,                       486, 684,  565,  25, _S7  ),
   wccreate( (board,6101),  edit,     `[]`,                        12, 684,  455,  25, _S7  ),

   wccreate( (board,1020),  button,   `Triangle`,                 930, 270,   70,  30, _S3  ),
   wccreate( (board,1021),  button,   `Circle`,                   930, 350,   70,  30, _S3  ),
   wccreate( (board,1022),  button,   `Square`,                   930, 310,   70,  30, _S3  ),
   wccreate( (board,1023),  button,   `Big`,                      530, 270,   70,  30, _S3  ),
   wccreate( (board,1024),  button,   `Medium`,                   530, 310,   70,  30, _S3  ),
   wccreate( (board,1025),  button,   `Small`,                    530, 350,   70,  30, _S3  ),
   wccreate( (board,12003), button,   `Size`,                     510, 240,  110, 160, _S4  ),
   wccreate( (board,12004), button,   `Shape`,                    910, 240,  110, 160, _S4  ),
   wccreate( (board,1026),  button,   `Top of`,                   730, 260,   70,  30, _S3  ),
   wccreate( (board,1027),  button,   `Bottom of`,                730, 340,   70,  30, _S3  ),
   wccreate( (board,1028),  button,   `Left of`,                  660, 300,   70,  30, _S3  ),
   wccreate( (board,1029),  button,   `Right of`,                 800, 300,   70,  30, _S3  ),
   wccreate( (board,12005), button,   ``,                         500,  30,  540, 160, _S4  ),
   wccreate( (board,20000), grafix,   `Grafix1`,                   22, 612,   30,  30, _S2  ),
   wccreate( (board,20001), grafix,   `Grafix1`,                   52, 612,   30,  30, _S2  ),
   wccreate( (board,20002), grafix,   `Grafix1`,                   82, 612,   30,  30, _S2  ),
   wccreate( (board,20003), grafix,   `Grafix1`,                  112, 612,   30,  30, _S2  ),
   wccreate( (board,20004), grafix,   `Grafix1`,                  142, 612,   30,  30, _S2  ),
   wccreate( (board,8002),  edit,     `40`,                       418,  68,   24,  20, _S6  ),
   wccreate( (board,11001), static,   `Number of shapes`,         328,  68,   90,  20, _S8  ),
   wccreate( (board,10000), grafix,   `Grafix106`,                 52, 572,   30,  30, _S2  ),
   wccreate( (board,10001), grafix,   `Grafix107`,                 82, 572,   30,  30, _S2  ),
   wccreate( (board,10002), grafix,   `Grafix108`,                112, 572,   30,  30, _S2  ),
   wccreate( (board,10003), grafix,   `Grafix109`,                192, 582,   50,  50, _S2  ),
   wccreate( (board,12006), button,   `Insert Shape`,              12, 552,  240, 100, _S4  ),
   wccreate( (board,8003),  edit,     `[medium,yellow,triangle]`, 264, 594,  196,  20, _S9  ),
   wccreate( (board,1030),  button,   `Save board`,               238,  58,   80,  30, _S3  ),
   wccreate( (board,10004), grafix,   `Grafix110`,                570, 588,   30,  30, _S2  ),
   wccreate( (board,10005), grafix,   `Grafix111`,                600, 588,   30,  30, _S2  ),
   wccreate( (board,10006), grafix,   `Grafix112`,                630, 588,   30,  30, _S2  ),
   wccreate( (board,10007), grafix,   `Grafix113`,                660, 588,   30,  30, _S2  ),
   wccreate( (board,10008), grafix,   `Grafix114`,                690, 588,   30,  30, _S2  ),
   wccreate( (board,12007), button,   `Color`,                    558, 570,  170,  60, _S4  ),
   wccreate( (board,14000), stripbar, `Stripbar1`,                474,  -6,    1, 726, _S10 ),
   wccreate( (board,1031),  button,   `Clear`,                    816, 136,   88,  32, _S3  ),
   wccreate( (board,11000), rich,     ``,                         904, 142,  134,  30, _S11 ),
   wccreate( (board,12008), button,   ``,                         786, 534,  210, 132, _S4  ),
   wccreate( (board,11002), static,   `№ of Steps`,               804, 558,   80,  26, _S12 ),
   wccreate( (board,11003), static,   `№ of shapes left`,         804, 594,   80,  24, _S12 ),
   wccreate( (board,3003),  button,   `Game Mode`,                804, 630,   80,  20, _S13 ),
   wccreate( (board,8000),  edit,     ``,                         912, 558,   54,  24, _S14 ),
   wccreate( (board,8004),  edit,     ``,                         912, 594,   54,  24, _S14 ),
   wccreate( (board,1032),  button,   `Reset board`,              906, 624,   72,  30, _S15 ),
   wccreate( (board,7000),  edit,     ``,                          12, 684,  455,  25, _S7  ),
   wmcreate( menu), 
   wmnuadd( menu, 2000, `&Insert`,   1000 ),
   wmnuadd( menu, 2000, `&Delete`, 1001 ),
   wmcreate(tools_menu),
   wmnuadd(tools_menu,2001,`&Cut`,1002),
   wmnuadd(tools_menu,2001,`&Copy`,1003),
   wmnuadd(tools_menu,2001,`&Paste`,1004),
   wmnuadd(tools_menu,2001,`&Delete`,1005),
   wmnuadd(tools_menu,2001,`&Select All`,1006).


list_dialog :- 
   _S1 = [ws_caption,dlg_ownedbyprolog,ws_sysmenu,ws_minimizebox],
   _S2 = [ws_child,ws_border,ws_tabstop,ws_visible,ws_vscroll,lbs_notify],
   _S3 = [ws_child,ws_visible,ss_center],
   _S4 = [ws_child,ws_tabstop,ws_visible,bs_pushbutton,bs_text,bs_center,bs_vcenter],
   _S5 = [ws_child,ws_border,ws_tabstop,es_left,es_multiline,es_autohscroll,es_autovscroll],
   wdcreate(  list_dialog,        `List of expressions - Game Mode`, 829, 294, 486, 439, _S1 ),
   wccreate( (list_dialog,4000),  listbox, `List1`,                   10,  50, 460, 290, _S2 ),
   wccreate( (list_dialog,11500), static,  `List of expressions`,     10,  20, 460,  20, _S3 ),
   wccreate( (list_dialog,1500),  button,  `Copy`,                    70, 360,  80,  30, _S4 ),
   wccreate( (list_dialog,1502),  button,  `Save`,                   330, 360,  80,  30, _S4 ),
   wccreate( (list_dialog,1501),  button,  `Copy All`,               200, 360,  80,  30, _S4 ),
   wccreate( (list_dialog,9000),  edit,    ``,                        10, 390, 460,  10, _S5 ),
   wccreate( (list_dialog,8000),  edit,    ``,                        10, 400, 460,  10, _S5 ),
   wlstadd((list_dialog,4000),0,`*`,0), 
   wfont((list_dialog,4000),2).


list_handler((list_dialog,N),msg_button,_,_):-
	N = 1500 -> copy_selected;
	N = 1501 -> copy_all;
	N = 1502 -> save_list.

list_handler( (list_dialog,4000), msg_select, Index, Result ):-
		
    	wlstget((list_dialog,4000),Index,String,_),
	wtext((list_dialog,8000),String).


copy_selected:-
	wtext((list_dialog,8000),S),
	len(S,Finish),
	wedtsel((list_dialog,8000),0,Finish),
	wedtclp((list_dialog,8000),2).

copy_all:- 
	wtext((list_dialog,9000),String),
	wlstfnd( (list_dialog,4000), -1,`*`, Match ),
	listar(ListaI,Match),
	member(A,ListaI,1), remove(A,ListaI,Lista),
	write(Lista)~>SLista,
	wtext((list_dialog,9000),SLista), len(SLista,Len),
	wedtsel((list_dialog,9000),0,Len),
	wedtclp((list_dialog,9000),2),
	wtext((list_dialog,9000),String).



save_list:-
	wlstfnd( (list_dialog,4000), -1,`*`, Match ),
	listar(Lista,Match),
	len(Lista,Len),
	(	Len = 1 -> msgbox(`Save list error`,`Empty list`,16,R);
		Len > 1 -> (
					member(A,Lista,1),
					remove(A,Lista,ListaF),
					savbox( `Save As...`,[(`Normal text file (*.txt)`,`*.txt`)], ``, `Text`,[File]),
					fcreate( File, File, -1, 0, 0 ),
						output( File ), 
						forall(member(X,ListaF),(write(X),write(`~M`))), 
						nl, 
						output( 0 ),
					fclose(File)
				);!
	). 		

listar( [P],0  ):- wlstget((list_dialog,4000),0,P,T).


listar( [P|Rest],N):-
	M is N-1, 
	wlstget((list_dialog,4000),N,P,T), 
	listar( Rest,M).

%%%		Creación de colores		
brush_colours :-
	gfx_brush_create( green,	  0,	255,	  0,	solid ),
	gfx_brush_create( blue,		  0,	  0,	255,	solid ),
	gfx_brush_create( red,		255,	  0,	  0,	solid ),
	gfx_brush_create( white,	255,	255,	255,	solid ),
   	gfx_brush_create( yellow,     255,	255,	  0,	solid ),
   	gfx_brush_create( cyan,         0,	255,	255,	solid ),
   	gfx_brush_create( black,        0,	  0,	  0,	solid ),
	gfx_brush_create( pink,		255,	140,	  0,	solid ),
	gfx_brush_create( pinkE,	255,	140,	  0,	diagcross ).


%%%		Creación de fuentes
font :-
	wfcreate( foo, arial, 19, 0 ),
	forall(integer_bound(1005,N,1018),catch(_,wfont((board,N),foo))),
	wfcreate( foo2, arial, 21, 0 ),
	wfont((board,1003),foo2),wfont((board,1004),foo2),
	wfont((board,5000),2),
	wfont((board,5001),2),
	wfont((board,8001),2),
	wfont((board,8003),2).

%%%		Cerrar la aplicacion al hacer click en la X
board_handler( _, msg_close, _, close ):-
	wbtnsel((board,3003),Status),
	(Status = 1 -> wclose(list_dialog);!),
	wclose(board).

board_main_hook:-
	(  	
		write( `Ambiente visual para el aprendizaje de sistemas~M~J` ),
		write(`formales~M~J`)
  	) ~> AboutString1,
  	bdsbox( AboutString1, 1 ),
  	pause( 1000 ),
	(  	
		write( `Desarrollado por:~M~J` ),
		write( `Camilo Aguado Bedoya~M~J~M~J`),
		write( `Director de proyecto:~M~J` ),
		write( `Raúl Alfredo Chaparro Aguilar~M~J~M~J` )
	) ~> AboutString2,
	bdsbox( AboutString2, 1 ),
  	pause( 1000 ),
	(  	
		write(`Proyecto de Grado~M~J`),
		write(`Ingeniería de Sistemas~M~J`),
		write(`Escuela Colombiana de Ingieniería Julio Garavito~M~J`)
 	) ~> AboutString3,
	bdsbox( AboutString3, 1 ),
  	pause( 1000 ),
 	bdsbox( ``, -1 ),
	board,set_operators,
	abort.

board_abort_hook:-    repeat,flag(1),wait(0),fail.