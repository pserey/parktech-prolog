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

estaciona(cpfCliente, placa, idVaga):- write('deu certo!!!').



horas(FINAL, INICIAL, HORAS) :-
    round(FINAL, DATE1),
    round(INICIAL, DATE2),
    HORAS is DATE1 - DATE2.

retorna_horas(TEMPO_VAGA, Horas) :-
    TEMPO_VAGA = RETORNO,
    Horas is RETORNO / 3600.

taxa_pagamento(IdVaga, IsDiaSemana, Taxa) :-
    consult('src/vagas.pl'),
    vaga(_, _, _, TipoVeiculo, TempoInicial, IdVaga,_),
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
    consult('src/vagas.pl'),
    vaga(Status, Vaga, Andar,TipoVeiculo,_,IdVaga,_),
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

tempo_vaga :- nl, write('tempo_vaga').