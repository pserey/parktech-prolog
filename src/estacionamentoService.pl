:- module(estacionamentoService, [
    estaciona_veiculo/0,
    paga_estacionamento/0,
    tempo_vaga/0
    ]).
:- use_module('menu.pl', [menu/0]).
:- use_module('util.pl', [input_line/1, posix_time/1]).
:- use_module('databaseManager.pl', [add_fact/2, update_fact/3]).
:- use_module('vagaService.pl', [find_vaga_by_id/2]).
:- use_module('clienteService.pl', [cadastra_cliente/1]).
:- use_module('veiculoService.pl', [cadastra_veiculo/1]).

% são dinamicos pois clausulas serão removidas, adicionadas e atualizadas
:- dynamic cliente/2.
:- dynamic veiculo/3.
:- dynamic historico/2.
:- dynamic vaga/7.

estaciona_veiculo :- 
    write('--- ESTACIONAR ---'), nl,
    write('Insira seu CPF: '), input_line(cpfCliente),
    (cliente(cpfCliente, _) ->  verificaVeiculo(cpfCliente) ; cadastra_cliente(cpfCliente), verificaVeiculo(cpfCliente)).


verificaVeiculo(CpfCliente) :- 
    write('Insira a placa do veículo: '), input_line(placa),
    (veiculo(_,placa,_) ->  verificaDisponibilidadeVaga(CpfCliente, placa) ; cadastra_veiculo(placa), verificaDisponibilidadeVaga(CpfCliente, placa)).


verificaDisponibilidadeVaga(cpfCliente, placa) :-
    write('--- VAGA RECOMENDADA ---'),
    % historico(cpfCliente, V),
    write('RECOMENDA VAGA AQUI'),
    
    write('se tiver vaga recomendada: A vaga recomendada para você é a vaga de número +++++ no andar +++++'),
    write('caso não tenha: não há vagas recomendadas para esse veículo'),

    write('Insira o andar que você deseja estacionar: '), input_line(andar),
    write('Insira a vaga que você deseja estacionar: '), input_line(vaga),
    
    veiculo(T, placa, _),
    (vaga(0,vaga,andar,T,_,ID,_) -> estaciona(cpfCliente, placa, ID) ; (write('Você não pode estacionar nessa vaga'), find_vagas(T, cpfCliente, placa))).


find_vagas(Tipo, cpfCliente, placa) :-
    findall(X,(vaga(0,_,_,T,_,X,_)),L), 
    nth0(1,L,R), 
    (R =:= [] -> write('Não há vagas disponíveis para esse veículo.');
    pega_primeiro_ultimo(R, P, U),
    write('A vaga escolhida não esta disponivel, mas voce pode estacionar o veiculo na vaga numero '),
    write(P),
    write('no andar'),
    write(U),
    write('Deseja estacionar nessa vaga? (S/N)'), input_line(resposta),
    (resposta =:= 'S' -> estaciona(cpfCliente, placa, R); verificaDisponibilidadeVaga(cpfCliente,placa))).

pega_primeiro_ultimo(S, P, U) :-
    atom_chars(S, Lista),
    [P | _] = Lista,
    reverse(Lista, [U | _]).

replace(_, _, [], []).
replace(Old, New, [Old|Tail], [New|NewTail]) :-
    replace(Old, New, Tail, NewTail).
replace(Old, New, [Head|Tail], [Head|NewTail]) :-
    Old \= Head,
    replace(Old, New, Tail, NewTail).

estaciona(CpfCliente, Placa, IdVaga) :- 
    % acesssa vaga
    find_vaga_by_id(IdVaga, Vaga),

    % atualiza vaga
    Vaga =.. List,
    List = [vaga, _, _, _, _, _, IdVaga, _],
    replace(none, Placa, List, NewList),
    NewVaga =.. NewList,
    
    % persiste atualização
    update_fact('src/vagas.pl', Vaga, NewVaga), !.

paga_estacionamento :- nl, write('paga_estacionamento').
tempo_vaga :- nl, write('tempo_vaga').