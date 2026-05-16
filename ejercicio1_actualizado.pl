personaje('Elara', 5, 100).
personaje('Kael', 3, 80).
personaje('Rin', 7, 120).

mision(m1, 'Bosque de Sombras', 2, 50).
mision(m2, 'Cueva del Dragón', 5, 120).
mision(m3, 'Torre Arcana', 7, 200).

inventario('Elara', [espada, escudo, pocion]).
inventario('Kael', [arco, flechas]).
inventario('Rin', [varita, grimorio, pocion, amuleto]).

requiere(m2, escudo).
requiere(m2, pocion).
requiere(m3, grimorio).
requiere(m3, pocion).

puede_aceptar(Personaje, ID_Mision) :-
    personaje(Personaje, Nivel, _),
    mision(ID_Mision, _, Dificultad, _), 
    Nivel >= Dificultad.

xp_acumulada(0, 0).

xp_acumulada(N, Total) :-
    N > 0,
    N1 is N - 1,
    xp_acumulada(N1, Prev),
    Total is Prev + (30 * N).

tiene_requisitos(Personaje, Objeto) :-
    inventario(Personaje, Lista),
    member(Objeto, Lista).

mismo_nivel(P1, P2) :-
    personaje(P1, N, _),
    personaje(P2, N, _),
    P1 \== P2.

es_balanceado(Personaje) :-
    personaje(Personaje, _, Vida),
    Vida =:= 100.

fusionar_equipo(P1, P2, EquipoFusionado) :-
    inventario(P1, L1),
    inventario(P2, L2),
    append(L1, L2, EquipoFusionado).

tiempo(presente).
tiempo(pasado).
tiempo(futuro).

persona(primera).
persona(segunda).  
persona(tercera).

numero(singular).
numero(plural).

ser(presente, tercera, singular, "es").
ser(pasado, tercera, singular, "fue").
ser(futuro, tercera, singular, "será").
ser(presente, primera, singular, "soy").
ser(presente, primera, plural, "somos").
ser(presente, tercera, plural, "son").
ser(pasado, tercera, plural, "fueron").
ser(futuro, tercera, plural, "serán").

conjugar_accion(Verbo, Tiempo, Persona, Numero, Conjugacion) :-
    tiempo(Tiempo),
    persona(Persona),
    numero(Numero),
    (
        Verbo = "ser" ->
        ser(Tiempo, Persona, Numero, R),
        Conjugacion = R
        ;
        Conjugacion = Verbo
    ).

generar_reporte(Personaje, MisionID, Mensaje) :-
    puede_aceptar(Personaje, MisionID),
    mision(MisionID, Nombre, _, XP),
    conjugar_accion("ser", presente, tercera, singular, FormaVerbal),
    atomic_list_concat(
        [Personaje, FormaVerbal, "capaz de completar", Nombre, "por", XP, "XP"],
        ' ',
        Mensaje
    ).

es_lista([]).
es_lista([_|_]).

entrada_a_grupo(Entrada, Entrada) :-
    es_lista(Entrada).

entrada_a_grupo(Entrada, [Entrada]) :-
    personaje(Entrada, _, _).

pueden_todos([], _).

pueden_todos([Personaje|Resto], MisionID) :-
    puede_aceptar(Personaje, MisionID),
    pueden_todos(Resto, MisionID).

inventario_grupo([], []).

inventario_grupo([Personaje|Resto], InventarioTotal) :-
    inventario(Personaje, InventarioPersonaje),
    inventario_grupo(Resto, InventarioResto),
    append(InventarioPersonaje, InventarioResto, InventarioTotal).

tiene_requisitos_mision(Inventario, MisionID) :-
    forall(requiere(MisionID, Objeto), member(Objeto, Inventario)).

xp_actualizada([], _, []).

xp_actualizada([Personaje|Resto], MisionID, [xp(Personaje, XP_Actual, XP_Mision, XP_Final)|Resultado]) :-
    personaje(Personaje, Nivel, _),
    xp_acumulada(Nivel, XP_Actual),
    mision(MisionID, _, _, XP_Mision),
    XP_Final is XP_Actual + XP_Mision,
    xp_actualizada(Resto, MisionID, Resultado).

reporte_inicio([Personaje], MisionID, Mensaje) :-
    mision(MisionID, Nombre, _, XP),
    conjugar_accion("ser", presente, tercera, singular, FormaVerbal),
    atomic_list_concat(
        [Personaje, FormaVerbal, "capaz de completar", Nombre, "por", XP, "XP"],
        ' ',
        Mensaje
    ).

reporte_inicio(Grupo, MisionID, Mensaje) :-
    Grupo = [_,_|_],
    mision(MisionID, Nombre, _, XP),
    conjugar_accion("ser", presente, tercera, plural, FormaVerbal),
    atomic_list_concat(Grupo, ', ', Nombres),
    atomic_list_concat(
        [Nombres, FormaVerbal, "capaces de completar", Nombre, "por", XP, "XP cada uno"],
        ' ',
        Mensaje
    ).

iniciar_mision(Entrada, MisionID, Mensaje, XP_Actualizada) :-
    entrada_a_grupo(Entrada, Grupo),
    Grupo = [_|_],
    pueden_todos(Grupo, MisionID),
    inventario_grupo(Grupo, Inventario),
    tiene_requisitos_mision(Inventario, MisionID),
    reporte_inicio(Grupo, MisionID, Mensaje),
    xp_actualizada(Grupo, MisionID, XP_Actualizada).

iniciar_mision(Entrada, MisionID, Mensaje) :-
    iniciar_mision(Entrada, MisionID, Mensaje, _).