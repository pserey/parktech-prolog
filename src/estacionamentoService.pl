:- module(estacionamentoService, [
    estaciona_veiculo/0,
    paga_estacionamento/0,
    tempo_vaga/0
    ]).
:- use_module('menu.pl', [menu/0]).
:- use_module('util.pl', [input_line/1, posix_time/1]).
:- use_module('databaseManager.pl', [add_fact/2, update_fact/3]).
:- use_module('vagaService.pl', [find_vaga_by_id/2, disponiibilidade_vaga/2, get_vaga_id/3]).
:- use_module('clienteService.pl', [cadastra_cliente/1, verifica_cliente/1]).
:- use_module('veiculoService.pl', [cadastra_veiculo/1, verifica_veiculo/1]).

% são dinamicos pois clausulas serão removidas, adicionadas e atualizadas
:- dynamic cliente/2.
:- dynamic veiculo/3.
:- dynamic historico/2.
:- dynamic vaga/7.

estaciona_veiculo :- 
    write('--- ESTACIONAR ---'), nl,
    write('Insira seu CPF: '), input_line(CpfClienteString), atom_number(CpfClienteString, CpfCliente),
    (verifica_cliente(CpfCliente) ->  verificaVeiculo(CpfCliente) ; cadastra_cliente(CpfCliente), verificaVeiculo(CpfCliente)).


verificaVeiculo(CpfCliente) :- 
    write('Insira a placa do veículo: '), input_line(Placa),
    (verifica_veiculo(Placa) ->  verificaDisponibilidadeVaga(CpfCliente, Placa) ; cadastra_veiculo(Placa), verificaDisponibilidadeVaga(CpfCliente, Placa)).


verificaDisponibilidadeVaga(CpfCliente, Placa) :-
    write('--- VAGA RECOMENDADA ---'),
    % historico(cpfCliente, V),
    write('RECOMENDA VAGA AQUI'),
    
    write('se tiver vaga recomendada: A vaga recomendada para você é a vaga de número +++++ no andar +++++'),
    write('caso não tenha: não há vagas recomendadas para esse veículo'),

    write('Insira o andar que você deseja estacionar: '), input_line(Andar),
    write('Insira a vaga que você deseja estacionar: '), input_line(Vaga),

    % pega id de vaga
    get_vaga_id(Vaga, Andar, ID),
    
    (disponiibilidade_vaga(Vaga, Andar) -> estaciona(CpfCliente, Placa, ID) ; (write('Você não pode estacionar nessa vaga'), find_vagas(T, CpfCliente, Placa))).


find_vagas(Tipo, CpfCliente, Placa) :-
    % acha vagas disponiveis para tipo de veículo
    findall(ID, vaga(0, _, _, Tipo, _, ID, _), Disponiveis), 

    (Disponiveis = [] -> write('Não há vagas disponíveis para esse veículo.') ; 

        nth0(0, Disponiveis, IdVaga), 
        pega_primeiro_ultimo_caractere(IdVaga, Vaga, Andar),
        write('A vaga escolhida não esta disponivel, mas voce pode estacionar o veiculo na vaga numero '),
        write(Vaga),
        write('no andar'),
        write(Andar),
        write('Deseja estacionar nessa vaga? (S/N)'), input_line(Resposta),

        (resposta = 'S' -> estaciona(CpfCliente, Placa, IdVaga) ; menu)).

pega_primeiro_ultimo_caractere(String, Primeiro, Ultimo) :-
    atom_chars(String, Lista),
    [Primeiro | _] = Lista,
    reverse(Lista, [Ultimo | _]).

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