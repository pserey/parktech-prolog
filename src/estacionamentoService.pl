:- module(estacionamentoService, [
    estaciona_veiculo/0,
    paga_estacionamento/0,
    tempo_vaga/0
    ]).
:- use_module('menu.pl', [menu/0]).
:- use_module('util.pl', [input_line/1, posix_time/1, most_repeated_element/2]).
:- use_module('databaseManager.pl', [add_fact/2, update_fact/3]).
:- use_module('vagaService.pl', [find_vaga_by_id/2, disponiibilidade_vaga/2, get_vaga_id/3, get_vaga_tipo/2, get_vaga_status/2, get_vagas_disponiveis_tipo/2, get_vaga_numero_andar/3, get_tempo_vaga/2, get_vaga_tipo/2]).
:- use_module('clienteService.pl', [cadastra_cliente/1, verifica_cliente/1, get_historico/2]).
:- use_module('veiculoService.pl', [cadastra_veiculo/1, verifica_veiculo/1, get_tipo_veiculo/2]).

% são dinamicos pois clausulas serão removidas, adicionadas e atualizadas
:- dynamic cliente/2.
:- dynamic veiculo/3.
:- dynamic historico/2.
:- dynamic vaga/7.

estaciona_veiculo :- 
    write('--- ESTACIONAR ---'), nl,
    write('Insira seu CPF: '), input_line(CpfClienteString), nl, atom_number(CpfClienteString, CpfCliente),
    (verifica_cliente(CpfCliente) ->  verificaVeiculo(CpfCliente) ; cadastra_cliente(CpfCliente), verificaVeiculo(CpfCliente)).


verificaVeiculo(CpfCliente) :- 
    write('Insira a placa do veículo: '), input_line(PlacaString), nl,
    atom_string(Placa, PlacaString),
    (verifica_veiculo(Placa) ->  verificaDisponibilidadeVaga(CpfCliente, Placa) ; cadastra_veiculo(Placa), verificaDisponibilidadeVaga(CpfCliente, Placa)).


verificaDisponibilidadeVaga(CpfCliente, Placa) :-
    write('--- VAGA RECOMENDADA ---'), nl,


    (recomenda_vaga(CpfCliente, VagaRec, AndarRec) -> write('A vaga recomendada para você é a vaga de número '), write(VagaRec), write(' no '), write(AndarRec), write('o andar ') ;
    write('Por enquanto não há vagas recomendadas para esse veículo')), nl,

    write('------------------------'), nl,

    write('Insira o andar que você deseja estacionar: '), input_line(AndarString), atom_number(AndarString, Andar), nl,
    write('Insira a vaga que você deseja estacionar: '), input_line(VagaString), atom_number(VagaString, Vaga), nl,

    % pega id de vaga
    get_vaga_id(Vaga, Andar, ID),
    get_vaga_tipo(ID, Tipo),
    get_tipo_veiculo(Placa, TipoVeiculo),
    (Tipo \= TipoVeiculo -> write('Seu veículo não pode estacionar nessa vaga, porque ela não comporta veículos desse tipo'), nl, menu ; true),

    (disponiibilidade_vaga(Vaga, Andar) -> estaciona(CpfCliente, Placa, ID), menu ; write('Você não pode estacionar nessa vaga, ela está ocupada.'), nl, find_vagas(Tipo, CpfCliente, Placa)).


recomenda_vaga(CPF, VagaRec, AndarRec) :-
    get_historico(CPF, Historico),
    most_repeated_element(Historico, IdVagaRec),
    get_vaga_numero_andar(IdVagaRec, VagaRec, AndarRec).


find_vagas(Tipo, CpfCliente, Placa) :-
    % acha vagas disponiveis para tipo de veículo
    get_vagas_disponiveis_tipo(Tipo, Disponiveis),

    (Disponiveis = [] -> write('Não há vagas disponíveis para esse veículo.') ; 

        nth0(0, Disponiveis, ID), 
        get_vaga_numero_andar(ID, Vaga, Andar), nl,
        write('A vaga escolhida não esta disponível, mas você pode estacionar o veículo na vaga '),
        write(Vaga),
        write(' do '),
        write(Andar), write('o andar.'), nl,
        write('Deseja estacionar nessa vaga? (s/n) '), input_line(RespostaString), atom_string(Resposta, RespostaString),

        (Resposta = 's' -> estaciona(CpfCliente, Placa, _IdVaga), menu; menu)).

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
    get_tempo_vaga(IdVaga, Tempo),
    posix_time(Now),

    % atualiza vaga
    Vaga =.. List,
    List = [vaga, _, _, _, _, _, IdVaga, _],
    replace(none, Placa, List, PlacaList),
    replace(0, 1, PlacaList, EstacionadaList),
    replace(Tempo, Now, EstacionadaList, TempoList),
    NewVaga =.. TempoList,
    
    % persiste atualização
    update_fact('src/vagas.pl', Vaga, NewVaga), 
    registra_historico(CpfCliente, IdVaga),
    nl, write('Veículo estacionado com sucesso!'), nl, !.

registra_historico(CPF, IDVaga) :-
    % ver se cliente já tem histórico
    % se tem, atualizar histórico e persistir
    % se não, adicionar histórico
    (get_historico(CPF, Historico) -> update_historico(CPF, IDVaga, Historico) ; add_fact('src/historico.pl', historico(CPF, [IDVaga]))).

update_historico(CPF, IDVaga, Historico) :-
    NewHistorico = [IDVaga | Historico],
    update_fact('src/historico.pl', historico(CPF, Historico), historico(CPF, NewHistorico)).

horas(FINAL, INICIAL, HORAS) :-
    round(FINAL, DATE1),
    round(INICIAL, DATE2),
    HORAS is DATE1 - DATE2.

retorna_horas(TEMPO_VAGA, Horas) :-
    TEMPO_VAGA = RETORNO,
    Horas is RETORNO / 3600.

taxa_pagamento(IdVaga, IsDiaSemana, Taxa) :-
    get_tempo_vaga(IdVaga, TempoInicial),
    get_vaga_tipo(IdVaga, TipoVeiculo),
    posix_time(Current),
    horas(Current, TempoInicial, Diferenca),
    retorna_horas(Diferenca, Hora),
    round(Hora, Horas),
    (TipoVeiculo == 'carro', Horas > 2, IsDiaSemana == 1 -> Taxa is 6 + ((Horas-2)*1.5) ;
    TipoVeiculo == 'carro', Horas > 2, IsDiaSemana == 0 -> Taxa is 8 + ((Horas-2)*2) ;
    TipoVeiculo == 'carro', Horas =< 2, IsDiaSemana == 1 -> Taxa is 6;
    TipoVeiculo == 'carro', Horas =< 2, IsDiaSemana == 0 -> Taxa is 8;
    TipoVeiculo == 'moto', Horas > 2, IsDiaSemana == 1 -> Taxa is 4 + ((Horas-2)*1) ;
    TipoVeiculo == 'moto', Horas > 2, IsDiaSemana == 0 -> Taxa is 6 + ((Horas-2)*1.5) ;
    TipoVeiculo == 'moto', Horas =< 2, IsDiaSemana == 1 -> Taxa is 4;
    TipoVeiculo == 'moto', Horas =< 2, IsDiaSemana == 0 -> Taxa is 6;
    TipoVeiculo == 'van', Horas > 2, IsDiaSemana == 1 -> Taxa is 8 + ((Horas-2)*2) ;
    TipoVeiculo == 'van', Horas > 2, IsDiaSemana == 0 -> Taxa is 10 + ((Horas-2)*2.5) ;
    TipoVeiculo == 'van', Horas =< 2, IsDiaSemana == 1 -> Taxa is 8;
    TipoVeiculo == 'van', Horas =< 2, IsDiaSemana == 0 -> Taxa is 10;
    true).

paga_estacionamento :-
    write('--- PAGAMENTO ---'),nl,
    write('Informe o numero do andar: '), input_line(AndarString),
    write('Informe o numero da vaga: '), input_line(VagaString),
    atom_number(AndarString, Andar),
    atom_number(VagaString, Vaga),
    get_vaga_id(Vaga,Andar,IdVaga),
    get_vaga_status(IdVaga,Status),
    (Status == 0 -> write('A vaga nao está ocupada, falha ao realizar o pagamento'),nl,menu;true),
    write('é Dia comercial? [Não: 0/ Sim: 1] '), input_line(WeekString),
    atom_number(WeekString, Week),
    taxa_pagamento(IdVaga, Week, Taxa),
    string_concatenation('O preço final é: R$ ', Taxa, Resultado),
    write(Resultado),nl,
    write('Faça o seu pagamento: '), input_line(Valor),
    atom_number(Valor, ValorPago),
    Troco is ValorPago - Taxa,
    string_concatenation('Estacionamento não foi pago. O valor da taxa R$', Taxa, Intermed),
    atom_concat(Intermed, ' é maior que o valor pago', Menor),
    string_concatenation('Seu troco é: R$ ', Troco, Maior),
    posix_time(Curr),
    (Troco < 0 -> write(Menor),nl,menu;
    Troco == 0 -> write('Estacionamento Pago com sucesso'),update_fact('src/vagas.pl',vaga(Status, Vaga, Andar,TipoVeiculo,_,IdVaga,_),vaga(0, Vaga, Andar,TipoVeiculo,Curr,IdVaga,'none')),nl,menu;
    Troco > 0 ->  write(Maior),update_fact('src/vagas.pl',vaga(Status, Vaga, Andar,TipoVeiculo,_,IdVaga,_),vaga(0, Vaga, Andar,TipoVeiculo,Curr,IdVaga,'none')),nl, menu).

string_concatenation(String, Int, Result) :-
    number_string(Int, IntString),
    atom_concat(String, IntString, Result).

tempo_vaga :- 
    write('Insira o número da vaga: '), input_line(VagaString), atom_number(VagaString, Vaga),
    write('Insira o número do andar: '), input_line(AndarString), atom_number(AndarString, Andar),
    get_vaga_id(Vaga, Andar, ID),
    get_tempo_vaga(ID, TempoInicial),
    posix_time(Now),
    TempoEstacionado is Now - TempoInicial,
    retorna_horas(TempoEstacionado, HorasOld),
    Horas is round(HorasOld),
    write(Horas), write(' horas.'), nl, menu.
