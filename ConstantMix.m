%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Constant Mix                                                            %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Input: Indice: Valori di Chiusura dell'Indice da Analizzare             % 
%        Investimento: Capitale da Investire                              %
%        Ripartizione: Ripartizione tra Azioni/Bond (0 < Ripart. < 1)     %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Output: Azioni: Quantità Investita in Azioni                            %
%         Bond: Quantità Investita in Bond                                %
%         Commissioni: Totale del Costo delle Commissioni di Acq/Vend     %
%         Totale: Totale Capitale alla Fine della Simulazione             %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [ Azioni, Bond, Commissioni, Totale ] = ConstantMix( Indice, Investimento, Ripartizione )
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % PASSO 0: a) Il Moltiplicatore deve essere compreso tra 0 e 1        %
    %          b) Inverto l'indice in ordine Crescente di data            %
    %          c) Inizializzo la Variabile per le Commissioni             %
    %          d) Inizializzo le Variabili per generare il Grafico        %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    if (Ripartizione > 1 || Ripartizione < 0)
        error('La Ripartizione deve essere compresa tra 0 e 1');
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

    Azioni = Ripartizione * Investimento;
    Bond = Investimento - Azioni;
    
    % Aggiorno le Variabili per il Grafico
    plot_portafoglio(1) = Investimento;
    plot_azioni(1) = Azioni;
    plot_bond(1) = Bond;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % PASSO 3: Aggiorno il Valore del Portafoglio (Giorno 2)              %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    Azioni = (1 + (r_i(2))/100) * Azioni;
    Investimento_Temporaneo = Azioni + Bond;
    Esposizione = Ripartizione * Investimento_Temporaneo;
    Vendita = Esposizione - Azioni;

    if (Vendita ~= 0)
        if ((Bond - Vendita) >= 0 && Esposizione >= 0)
            Azioni = Esposizione;
            Bond = Bond - Vendita;
        elseif (Bond - Vendita < 0)
            Bond = 0;
        else
            Azioni = 0;
        end
        Investimento_Temporaneo = Azioni + Bond;
        Commissioni = Commissioni + 2;
    end
    
    % Aggiorno le Variabili per il Grafico
    plot_portafoglio(2) = Investimento_Temporaneo - Commissioni;
    plot_azioni(2) = Azioni;
    plot_bond(2) = Bond;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % PASSO 4: Applico la Strategia Dinamica al Portafoglio (Giorno 3..N) %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    for i = 3:length(Indice)
        Azioni = (1 + (r_i(i))/100) * Azioni;
        Investimento_Temporaneo = Azioni + Bond;
        Esposizione = Ripartizione * Investimento_Temporaneo;
        Vendita = Esposizione - Azioni;

        if (Vendita ~= 0)
            if ((Bond - Vendita) >= 0 && Esposizione >= 0)
                Azioni = Esposizione;
                Bond = Bond - Vendita;
            elseif (Bond - Vendita < 0)
                Bond = 0;
            else
                Azioni = 0;
            end
            Investimento_Temporaneo = Azioni + Bond;
            Commissioni = Commissioni + 2;
        end

        % Aggiorno le Variabili per il Grafico
        plot_portafoglio(i) = Investimento_Temporaneo - Commissioni;
        plot_azioni(i) = Azioni;
        plot_bond(i) = Bond;
    end
    
    % Aggiorno il Totale con l'Investimento Temporaneo meno le Commissioni
    Totale = Investimento_Temporaneo - Commissioni;

    % Imposto e Stampo le Informazioni del Grafico
    hold on;
    plot(plot_bond, 'r');
    plot(plot_azioni, 'g');
    plot(plot_portafoglio, 'b');
    legend('Bond', 'Azioni', 'Portafoglio');
    title('Risultato della Strategia ConstantMix');
    xlabel('Giorni');
    ylabel('Valore (€)');
    
end
