# AgentChat

Un'applicazione iOS/macOS per chat con assistenti AI multipli, sviluppata in SwiftUI.

## Caratteristiche

- **Provider AI Multipli**: Supporta OpenAI, Anthropic, Mistral, Perplexity, n8n e provider personalizzati
- **Gestione Sicura delle API Key**: Utilizza il Keychain di iOS per memorizzare le chiavi API
- **Interfaccia Moderna**: Sviluppata con SwiftUI per iOS e macOS
- **Configurazione Flessibile**: Possibilità di aggiungere provider personalizzati
- **Gestione Chat**: Creazione, visualizzazione e gestione di multiple conversazioni

## Struttura del Progetto

```
AgentChat/
├── Models/
│   ├── AssistantProvider.swift     # Modelli per i provider AI
│   └── ProviderModels.swift        # Modelli di richiesta/risposta
├── Services/
│   ├── KeychainService.swift       # Gestione sicura delle API key
│   ├── LocalAssistantConfiguration.swift # Configurazione provider
│   ├── N8NService.swift            # Servizio per workflow n8n
│   └── UniversalAssistantService.swift   # Servizio unificato AI
├── Views/
│   ├── APIKeyConfigView.swift      # Configurazione API key
│   ├── ChatDetailView.swift        # Vista dettaglio chat
│   ├── CustomProviderView.swift    # Aggiunta provider personalizzati
│   ├── NewChatView.swift           # Creazione nuova chat
│   └── SettingsView.swift          # Impostazioni applicazione
├── ContentView.swift               # Vista principale
├── AgentChatApp.swift             # Entry point applicazione
└── OpenAIAssistantService.swift   # Servizio specifico OpenAI
```

## Provider Supportati

### Anthropic (Claude)
- Claude 4 (Opus, Sonnet)
- Claude 3.5 (Sonnet, Haiku)
- Claude 3.7 (Sonnet)
- Claude 3 (Opus, Sonnet, Haiku)

### OpenAI
- GPT-4 Omni
- GPT-4.1 (Standard, Mini)
- GPT-4 Turbo (Standard, Vision)
- GPT-3.5 Turbo

### Perplexity
- Sonar Pro (Online)
- Sonar Reasoning
- Sonar Deep Research
- Llama 3.1 (405B, 70B)
- Mixtral 8x7B

### Mistral AI
- Mistral Large/Small
- Devstral (Code)
- Magistral (Reasoning)
- Pixtral (Vision)
- Voxtral (Audio)

### XAI (Grok)
- Grok 4
- Grok 1.5 (Standard, Vision)

## Funzionalità Principali

### Gestione Provider
- Attivazione/disattivazione provider
- Configurazione API key sicura
- Aggiunta provider personalizzati
- Test connessione provider

### Chat
- Creazione nuove conversazioni
- Selezione provider e modello
- Cronologia messaggi
- Gestione multiple chat

### Sicurezza
- API key memorizzate nel Keychain
- Nessuna persistenza in chiaro delle credenziali
- Validazione input utente

## Requisiti

- iOS 15.0+ / macOS 12.0+
- Xcode 14.0+
- Swift 5.7+

## Installazione

1. Clona il repository
2. Apri `AgentChat.xcodeproj` in Xcode
3. Compila ed esegui il progetto

## Configurazione

1. Avvia l'applicazione
2. Vai nelle Impostazioni (icona ingranaggio)
3. Configura le API key per i provider desiderati
4. Attiva i provider che vuoi utilizzare
5. Crea una nuova chat selezionando provider e modello

## Note Tecniche

- Utilizza il pattern Singleton per i servizi
- Implementa ObservableObject per la reattività SwiftUI
- Gestione errori centralizzata
- Architettura modulare e estensibile

## Licenza

Questo progetto è sviluppato per scopi educativi e di ricerca.