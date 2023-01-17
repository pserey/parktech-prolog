:- module(vagaService, [
    vagasDisponiveis/0,
    vagasDisponiveisAndar/0,
    adicionaVaga/0,
    adicionaAndar/0,
    adicionaTempoVaga/0
    ]).
:- use_module('menu.pl', [menu/0]).

vagasDisponiveis :- write('vagasDisponiveis').
vagasDisponiveisAndar :- write('vagasDisponiveisAndar').
adicionaVaga :- 
    write('numero: '),
    read(Numero),
    write('andar: '),
    read(Andar),
    write('tipo de veiculo: '),
    read(TipoVeiculo),
    write(vaga(Numero, Andar, TipoVeiculo)), nl,
    write('vaga cadastrada!'), nl.
adicionaAndar :- write('adicionaAndar').
adicionaTempoVaga :- write('adicionaTempoVaga').