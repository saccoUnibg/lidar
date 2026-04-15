# Rilevamento e Analisi del Movimento dei Ciclisti

## Introduzione
Il crescente interesse verso la mobilità ciclabile e le attività sportive su due ruote ha stimolato lo sviluppo di sistemi intelligenti per l’analisi del movimento dei ciclisti.  
Questo progetto si concentra sul rilevamento e sull’analisi del comportamento dei ciclisti in un **bike park** dedicato, un ambiente controllato che ospita esclusivamente biciclette.  
Il modello impiegato è **SECOND (Sparse Embedded Convolutional Detection)**, adattato per il rilevamento e lo studio del movimento in scenari tridimensionali basati su dati LiDAR.

## Obiettivi
Il progetto si propone di:
- Rilevare e tracciare i ciclisti all’interno di un bike park utilizzando il modello **SECOND**.  
- Analizzare **inclinazione**, **velocità** e **traiettoria** dei ciclisti durante il movimento.  
- Effettuare la **classificazione del tipo di bicicletta**, distinguendo tra **bici da corsa** e **mountain bike**.  
- Valutare le prestazioni del modello in un contesto controllato, privo di altri tipi di veicoli.

## Setup Sperimentale
L’esperimento è stato condotto all’interno di un **bike park** attrezzato con un sistema di rilevamento basato su sensore **LiDAR RS128**.  
Il sensore, prodotto da **RoboSense**, è caratterizzato da:
- 128 canali di scansione e un ampio **campo visivo verticale di 40°**;  
- una **frequenza di scansione fino a 20 Hz**;  
- una **portata massima di circa 200 metri**;  
- una **risoluzione angolare** adatta all’acquisizione dettagliata dei profili dei ciclisti.  

Il sensore è stato posizionato in modo da coprire un’ampia porzione del tracciato, consentendo di catturare i movimenti dei ciclisti da diverse angolazioni e velocità.  
I dati LiDAR grezzi sono stati successivamente processati per generare **point cloud tridimensionali** utilizzati come input per il modello SECOND.

## Metodologia
1. **Raccolta Dati**  
   I dati LiDAR sono stati acquisiti durante le sessioni di prova dei ciclisti nel bike park, con diverse traiettorie e andature.  
   Ogni sequenza è stata sincronizzata e annotata per consentire la validazione del modello.

2. **Modello Utilizzato: SECOND**  
   Il modello **SECOND**, basato su convoluzioni sparse 3D, è stato adattato per rilevare i ciclisti nei point cloud generati dal RS128.  
   Il modello produce bounding box tridimensionali per ogni ciclista, da cui vengono estratti parametri cinematici.

3. **Elaborazione e Analisi**  
   - Calcolo della **velocità** a partire dalle variazioni di posizione tra frame consecutivi.  
   - Stima dell’**inclinazione** del ciclista in base all’orientamento del bounding box 3D.  
   - Analisi della **traiettoria** per individuare curve, accelerazioni e variazioni di direzione.  
   - **Classificazione** del tipo di bicicletta (corsa o MTB) attraverso feature geometriche e cinematiche.  

4. **Validazione**  
   Le misure ottenute sono state confrontate con annotazioni di riferimento e osservazioni dirette per valutare l’accuratezza del sistema.

## Risultati
- Il modello **SECOND** ha rilevato e tracciato i ciclisti con elevata precisione nei dati LiDAR RS128.  
- Le stime di **velocità**, **inclinazione** e **traiettoria** hanno mostrato coerenza con i dati di riferimento.  
- La **classificazione** tra bici da corsa e mountain bike ha raggiunto un’elevata accuratezza grazie all’integrazione tra parametri morfologici e cinematici.

## Applicazioni
- **Analisi Sportiva:** Valutazione delle prestazioni dei ciclisti e del comportamento dinamico durante il percorso.  
- **Sicurezza Dinamica:** Studio delle situazioni di rischio e ottimizzazione del tracciato.  
- **Ricerca Tecnologica:** Validazione di modelli di *object detection* 3D in ambienti controllati e specifici per la mobilità ciclistica.

## Conclusione
L’utilizzo del sensore **LiDAR RS128** in combinazione con il modello **SECOND** ha permesso di sviluppare un sistema efficace per il rilevamento e l’analisi del movimento dei ciclisti in un ambiente controllato.  
I risultati ottenuti dimostrano la potenzialità di questa configurazione per applicazioni future in ambito sportivo, di sicurezza e di ricerca sulla dinamica del movimento.

---
*Sviluppato come parte di un progetto di ricerca sull’analisi automatica del movimento ciclistico in ambienti controllati basata su sensori LiDAR.*