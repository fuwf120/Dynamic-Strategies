%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Buy & Hold                                                              %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Input: Indice: Valori di Chiusura dell'Indice da Analizzare             % 
%        Investimento: Capitale da Investire                              %      
%        Obbligazioni: Quantità investita in Bond                         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Output: Azioni: Quantità Investita in Azioni                            %
%         Bond: Quantità Investita in Bond                                %
%         Totale: Totale Capitale alla Fine della Simulazione             %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [ Azioni, Bond, Commissioni, Totale ] = BuyHold( Indice, Investimento, Obbligazioni )

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % PASSO 0: a) Le Obbligazioni devono essere MINORI dell'Investimento  %
    %          b) Inverto l'indice in ordine Crescente di data            %
    %          c) Inizializzo le Commissioni a 0                          %
    %          d) Inizializzo le Variabili per generare il Grafico        %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    if (Obbligazioni > Investimento)
        error('Le Obbligazioni NON DEVONO superare l''Investimento.');
    end

    Indice = Indice(end:-1:1);
    
    Commissioni = 0;
    
    plot_portafoglio = zeros(1, length(Indice)-1);
    plot_azioni = zeros(1, length(Indice)-1);
    plot_bond = zeros(1, length(Indice)-1);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % PASSO 1: Calcolo il Rendimento Giornaliero dell'Indice              %
    %          Formula: 100*((Pi - Pi-1)/Pi-1)                            %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    r_i = zeros(1, length(Indice)-1);
    pi_1 = Indice(1);
    
    for i = 2:length(Indice)
        pi = Indice(i);
        r_i(i) = 100*((pi - pi_1)/pi_1);
        pi_1 = pi;
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % PASSO 2: Inizializzazione del Portafoglio (Giorno 1)                %
    %          Formula: Azioni = Moltiplicatore * Investimento            %
    %                   Bond = Investimento - Azioni                      %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    Azioni = Investimento - Obbligazioni;
    Bond = Obbligazioni;
    
    % Aggiorno le Variabili per il Grafico
    plot_portafoglio(1) = Investimento;
    plot_azioni(1) = Azioni;
    plot_bond(1) = Bond;

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % PASSO 3: Aggiorno il Valore del Portafoglio (Giorno 2)              %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    Azioni = (1 + (r_i(2))/100) * Azioni;
    Investimento_Temporaneo = Azioni + Bond;

    % Aggiorno le Variabili per il Grafico
    plot_portafoglio(2) = Investimento_Temporaneo;
    plot_azioni(2) = Azioni;
    plot_bond(2) = Bond;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % PASSO 4: Applico la Strategia Dinamica al Portafoglio (Giorno 3..N) %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    for i = 3:length(Indice)
        Azioni = (1 + (r_i(i))/100) * Azioni;
        Investimento_Temporaneo = Azioni + Bond;

        % Aggiorno le Variabili per il Grafico
        plot_portafoglio(i) = Investimento_Temporaneo;
        plot_azioni(i) = Azioni;
        plot_bond(i) = Bond;
    end
    
    % Aggiorno il Totale con l'Investimento Temporaneo
    Totale = Investimento_Temporaneo;

    % Imposto e Stampo le Informazioni del Grafico
    hold on;
    plot(plot_bond, 'r');
    plot(plot_azioni, 'g');
    plot(plot_portafoglio, 'b');
    legend('Bond', 'Azioni', 'Portafoglio');
    title('Risultato della Strategia Buy & Hold');
    xlabel('Giorni');
    ylabel('Valore (€)');
    
end
