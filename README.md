# StreamTV — Netflix-style para Fire TV / Google TV

App Flutter de streaming estilo Netflix para Android TV, Fire TV e Google TV.

## 📁 Estrutura do Projeto

```
lib/
├── main.dart                    # Entrada da app
├── models/
│   └── channel.dart             # Modelo de canal
├── providers/
│   └── channel_provider.dart    # Lógica M3U + estado
├── screens/
│   ├── home_screen.dart         # Ecrã principal (estilo Netflix)
│   └── player_screen.dart       # Player de vídeo
└── widgets/
    ├── featured_banner.dart     # Banner hero (topo)
    ├── category_row.dart        # Linha horizontal por categoria
    └── channel_card.dart        # Card individual do canal
```

---

## 🚀 Como compilar o APK (sem instalar nada)

### Opção 1 — Codemagic (recomendado, grátis)

1. Cria conta em https://codemagic.io
2. Liga ao GitHub e faz upload deste projeto
3. Configura: Flutter > Android > Build APK
4. Clica "Start build" → APK gerado automaticamente

### Opção 2 — GitHub Codespaces

1. Cria repositório no GitHub com este código
2. Abre Codespaces no browser
3. Corre:
   ```bash
   sudo apt-get update
   sudo apt-get install -y openjdk-17-jdk
   git clone https://github.com/flutter/flutter.git
   export PATH="$PATH:`pwd`/flutter/bin"
   flutter pub get
   flutter build apk --release
   ```
4. APK em: `build/app/outputs/flutter-apk/app-release.apk`

### Opção 3 — PC local (mais rápido)

1. Instala Flutter: https://flutter.dev/docs/get-started/install
2. Instala Android Studio
3. Corre:
   ```bash
   flutter pub get
   flutter build apk --release
   ```

---

## 📺 Instalar no Fire TV

1. Ativa "Opções de programador" nas definições do Fire TV
2. Liga ADB: `adb connect <IP_DO_FIRETV>`
3. Instala: `adb install app-release.apk`

Ou usa a app **Downloader** no Fire TV para instalar via URL.

---

## ⚙️ Configurações

Para mudar a URL M3U, edita `lib/providers/channel_provider.dart`:

```dart
static const String m3uUrl = 'A_TUA_URL_AQUI';
```

---

## 📦 Dependências

- `provider` — gestão de estado
- `http` — carregar lista M3U
- `video_player` — reprodutor de vídeo
- `cached_network_image` — cache de imagens
