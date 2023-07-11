:- encoding(utf8).
% Define las cuentas bancarias como hechos
:- dynamic usuario/3.
usuario(4552, 452, 1000).
usuario(2554, 254, 500).
usuario(3698, 369, 2000).

% Almacena las relaciones de passwords y cuentas para cambiar las
% credenciales
:- dynamic contrasenha/2.
contrasenha(452, 4552).
contrasenha(254, 2554).
contrasenha(369, 3698).

%%TODO eliminar _ innecesarios

%Almacena todos los movimientos realizados en el banco
:- dynamic estados_de_cuenta/3.

% Solicita las credenciales para dar acceso cuando se quiera consultar
% el saldo
consultar_saldo :-
    write('Ingrese su cuenta:'), nl,
    read(Cuenta),
    write('Ingrese su NIP: '), nl,
    read(NIP), consultar(Cuenta, NIP).

% Valida las credenciales y consulta el saldo de la cuenta y en caso de
% ser correctas, muestra el saldo de la cuenta usada
consultar(Cuenta, NIP) :-
    usuario(Cuenta, NIP, Saldo),
    contrasenha(NIP, Cuenta),
    format('Su saldo es: ~w', Saldo), nl,
    assertz(estados_de_cuenta(Cuenta, 'Consulta', 'Exitosa'));
    write('Credenciales no validas'), nl.

% Solicita credenciales para validacion de datos para depositar dinero
depositar_dinero :-
    write('Ingrese su cuenta:'), nl,
    read(Cuenta),
    write('Ingrese su NIP: '), nl,
    read(NIP), depositar(Cuenta, NIP).

% Valida las credenciales dadas en depositar_dinero
depositar(Cuenta, NIP) :-
    usuario(Cuenta, NIP, Saldo),
    contrasenha(NIP, Cuenta),
    deposito(Cuenta, Saldo);
    write('Credenciales no validas'), nl, menu.

% Solicita el monto  y realiza el deposito
deposito(Cuenta, Saldo) :- write('Ingrese la cantidad a depositar: '),nl,
    read(Cantidad),
    NuevoSaldo is Saldo + Cantidad,
    retract(usuario(Cuenta, NIP, Saldo)),
    asserta(usuario(Cuenta, NIP, NuevoSaldo)),
    format('Nuevo saldo: ~w', NuevoSaldo),
    assertz(estados_de_cuenta(Cuenta, 'Deposito Exitoso', Cantidad)),
    nl;
    write('Operacion invalida').

% Solicita las credenciales del cliente para obtener los datos del
% estado de cuenta
estado_de_cuenta :-
    write('Ingrese su cuenta:'), nl,
    read(Cuenta),
    write('Ingrese su NIP: '), nl,
    read(NIP), estado(Cuenta, NIP).

%Obtiene los datos y los valida para dar acceso al estado de cuenta
estado(Cuenta, NIP) :- usuario(Cuenta, NIP, Saldo),
    contrasenha(NIP, Cuenta), estado_cuenta(Cuenta, Saldo);
    write('Credenciales no validas'), nl.

% Realiza la busqueda de acciones realizadas en el banco y que se han
% guardado en estado_de_cuenta/3.
estado_cuenta(Cuenta, Saldo) :- format('Su saldo es: ~w', Saldo),
    estados_de_cuenta(Cuenta, X, Y), nl,
    write('Movimientos: '), nl,
    write((Cuenta, X, Y)),nl.

% Solicita credenciales para validacion de datos para transferir dinero
transferir_dinero :-
    write('Ingrese su cuenta:'), nl,
    read(Cuenta),
    write('Ingrese su NIP: '), nl,
    read(NIP), transferir(Cuenta, NIP).

%Valida las credenciales dadas en tranferir_dinero
transferir(Cuenta, NIP) :-
    usuario(Cuenta, NIP, Saldo),
    contrasenha(NIP, Cuenta),
    transferencia(Cuenta, Saldo);
    write('Credenciales no validas'), nl.

% Regla para crear una cuenta bancaria
crearCuenta(ID, Nombre, SaldoInicial) :-
    assertz(cuenta(ID, Nombre, SaldoInicial)).

% Regla para leer una cuenta bancaria
leerCuenta(ID, Nombre) :-
    cuenta(ID, Nombre, Saldo), write(Saldo).

% Regla para actualizar una cuenta bancaria
actualizarCuenta(ID, NuevoSaldo) :-
    retract(cuenta(ID, Nombre, _)),
    assertz(cuenta(ID, Nombre, NuevoSaldo)).

% Regla para eliminar una cuenta bancaria
eliminarCuenta(ID) :-
    retract(cuenta(ID, _, _)).

% Solicita la cuenta a donde se enviaran los datos, el monto y realiza
% la operacion
transferencia(Cuenta, Saldo) :- write('Ingrese la cuenta destino: '),
    nl,
    read(CuentaDestino),
    write('Ingrese la cantidad a transferir: '), nl,
    read(Cantidad),
    Saldo >= Cantidad,
    NuevoSaldoOrigen is Saldo - Cantidad,
    NuevoSaldoOrigen>=0,
    retract(usuario(Cuenta, NIP, Saldo)),
    asserta(usuario(Cuenta, NIP, NuevoSaldoOrigen)),
    usuario(CuentaDestino, NIPDestino, SaldoDestino),
    NuevoSaldoDestino is SaldoDestino + Cantidad,
    retract(usuario(CuentaDestino, NIPDestino, SaldoDestino)),
    asserta(usuario(CuentaDestino, NIPDestino, NuevoSaldoDestino)),
    assert(estados_de_cuenta(Cuenta, 'Transferencia', Cantidad)),
    write('Transferencia exitosa'), nl,
    format('Nuevo saldo: ~w', NuevoSaldoOrigen), nl;
    assert(estados_de_cuenta(Cuenta, 'Transferencia fallida', Cantidad)),
    write('Cuenta y/o cantidad no disponible').