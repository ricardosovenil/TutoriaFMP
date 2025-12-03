# FMP - Sistema de Tutoria

Sistema de tutoria desenvolvido em Flutter para gerenciamento de estudantes, tutores e coordenadores.

> 💡 **Dica rápida**: Se você vai usar o **Android Studio**, vá direto para a seção [**"Opção 1: Rodar no Android Studio"**](#opção-1-rodar-no-android-studio-recomendado) abaixo!

## 📋 Pré-requisitos

Antes de começar, certifique-se de ter instalado:

1. **Flutter SDK** (versão 3.3.0 ou superior)
   - Baixe em: https://docs.flutter.dev/get-started/install
   - Verifique a instalação executando: `flutter doctor`

2. **Dart SDK** (vem junto com o Flutter)

3. **Editor de código** (recomendado):
   - Visual Studio Code com extensão Flutter
   - Android Studio com plugins Flutter e Dart

4. **Para desenvolvimento Android:**
   - Android Studio
   - Android SDK
   - Um emulador Android configurado ou dispositivo físico com modo desenvolvedor ativado

5. **Para desenvolvimento iOS (apenas macOS):**
   - Xcode
   - CocoaPods

## 🚀 Como rodar o projeto

### Opção 1: Rodar no Android Studio (Recomendado)

#### 1. Instale o Android Studio
- Baixe em: https://developer.android.com/studio
- Durante a instalação, certifique-se de instalar:
  - Android SDK
  - Android SDK Platform
  - Android Virtual Device (AVD)

#### 2. Configure o Flutter no Android Studio
1. Abra o Android Studio
2. Vá em **File → Settings** (ou **Android Studio → Preferences** no macOS)
3. Clique em **Plugins**
4. Procure e instale os plugins:
   - **Flutter** (isso também instala o plugin Dart automaticamente)
5. Reinicie o Android Studio

#### 3. Configure o Flutter SDK
1. Vá em **File → Settings → Languages & Frameworks → Flutter**
2. Clique em **Flutter SDK path** e selecione a pasta onde você instalou o Flutter
   - Exemplo: `C:\src\flutter` (Windows) ou `/usr/local/flutter` (Linux/Mac)
3. Clique em **Apply** e depois **OK**

#### 4. Abra o projeto
1. No Android Studio, clique em **File → Open**
2. Navegue até a pasta `flutter_application_1` e selecione-a
3. Clique em **OK**
4. O Android Studio vai pedir para confiar no projeto - clique em **Trust Project**

#### 5. Instale as dependências
1. No terminal do Android Studio (parte inferior), execute:
   ```bash
   flutter pub get
   ```
   Ou clique com o botão direito no arquivo `pubspec.yaml` e selecione **Flutter → Pub Get**

#### 6. Configure um emulador Android
1. No Android Studio, clique no ícone **Device Manager** (ícone de celular) na barra de ferramentas
2. Clique em **Create Device**
3. Escolha um dispositivo (ex: Pixel 5)
4. Escolha uma imagem do sistema (recomendado: API 33 ou superior)
5. Clique em **Finish**
6. Clique no botão ▶️ (Play) ao lado do emulador criado para iniciá-lo

#### 7. Execute o aplicativo
1. Certifique-se de que o emulador está rodando (ou conecte um dispositivo físico)
2. No topo do Android Studio, você verá um dropdown com os dispositivos disponíveis
3. Selecione o emulador ou dispositivo desejado
4. Clique no botão ▶️ **Run** (ou pressione `Shift + F10`)
5. Aguarde o build e o aplicativo será instalado e executado automaticamente!

---

### Opção 2: Rodar pelo Terminal/CMD

#### 1. Clone o repositório (se ainda não tiver)

```bash
git clone <url-do-repositório>
cd flutter_application_1
```

#### 2. Instale as dependências

Execute o comando para baixar todas as dependências do projeto:

```bash
flutter pub get
```

#### 3. Verifique se tudo está configurado

Execute o comando para verificar se há algum problema na configuração:

```bash
flutter doctor
```

Certifique-se de que todos os itens necessários estão marcados como OK.

#### 4. Execute o aplicativo

**No Android:**
```bash
flutter run
```

**No iOS (apenas macOS):**
```bash
flutter run
```

**Em um dispositivo específico:**
```bash
# Listar dispositivos disponíveis
flutter devices

# Executar em um dispositivo específico
flutter run -d <device-id>
```

**No Windows:**
```bash
flutter run -d windows
```

**No Linux:**
```bash
flutter run -d linux
```

**No navegador (Web):**
```bash
flutter run -d chrome
```

## 📦 Dependências do Projeto

O projeto utiliza as seguintes dependências principais:

- `sqflite: ^2.3.0` - Banco de dados SQLite local
- `path: ^1.8.3` - Manipulação de caminhos de arquivos
- `intl: ^0.19.0` - Internacionalização e formatação de datas/números
- `cupertino_icons: ^1.0.8` - Ícones do iOS

## 🗂️ Estrutura do Projeto

```
flutter_application_1/
├── lib/
│   ├── main.dart                    # Arquivo principal
│   ├── database/
│   │   └── database_helper.dart     # Configuração do banco de dados
│   ├── models/                      # Modelos de dados
│   ├── screens/                      # Telas do aplicativo
│   ├── services/                     # Serviços e lógica de negócio
│   └── enums/                        # Enumerações
├── assets/
│   └── logo_fmp.png                  # Logo do aplicativo
├── android/                          # Configurações Android
├── ios/                              # Configurações iOS
└── pubspec.yaml                      # Configurações e dependências
```

## 🔧 Solução de Problemas

### Erro: "No devices found"
- Certifique-se de que um emulador está rodando ou um dispositivo está conectado
- Para Android: Abra o Android Studio e inicie um emulador pelo Device Manager
- Para iOS: Abra o Simulator pelo Xcode
- No Android Studio: Verifique se o emulador aparece no dropdown de dispositivos no topo

### Erro: "pub get failed"
- Verifique sua conexão com a internet
- Execute `flutter clean` e depois `flutter pub get` novamente
- Verifique se a versão do Flutter está compatível (>=3.3.0)
- No Android Studio: Clique com botão direito em `pubspec.yaml` → **Flutter → Pub Get**

### Erro: "Flutter SDK not found" no Android Studio
- Vá em **File → Settings → Languages & Frameworks → Flutter**
- Configure o caminho do Flutter SDK corretamente
- Reinicie o Android Studio após configurar

### Erro: Plugins Flutter/Dart não encontrados
- Vá em **File → Settings → Plugins**
- Procure por "Flutter" e "Dart" e certifique-se de que estão instalados e habilitados
- Se não estiverem, instale-os e reinicie o Android Studio

### Erro ao executar no Android
- Verifique se o Android SDK está instalado e configurado
- Execute `flutter doctor` para verificar problemas
- Pode ser necessário aceitar as licenças do Android: `flutter doctor --android-licenses`
- No Android Studio: Verifique se o Android SDK está configurado em **File → Settings → Appearance & Behavior → System Settings → Android SDK**

### Erro: "Gradle build failed"
- No Android Studio, vá em **File → Invalidate Caches → Invalidate and Restart**
- Ou execute no terminal: `cd android && ./gradlew clean` (Linux/Mac) ou `cd android && gradlew.bat clean` (Windows)
- Depois execute `flutter clean` e `flutter pub get` novamente

### Erro ao executar no iOS
- Certifique-se de que o CocoaPods está instalado: `sudo gem install cocoapods`
- Entre na pasta `ios` e execute: `pod install`
- Verifique se o Xcode está atualizado

### O emulador não inicia
- Verifique se o Hyper-V está desabilitado (Windows) ou se a virtualização está habilitada no BIOS
- Tente criar um novo emulador com menos recursos (menos RAM, resolução menor)
- Verifique se há espaço suficiente no disco

## 📱 Funcionalidades

- Sistema de autenticação para Estudantes, Tutores e Coordenadores
- Gerenciamento de agendamentos
- Sistema de avaliações
- Notificações
- Relatórios (para coordenadores)

## 👥 Usuários Padrão

O sistema cria automaticamente um usuário administrador ao iniciar pela primeira vez. Consulte o código em `lib/database/database_helper.dart` para mais detalhes.

## 📝 Notas Importantes

- O banco de dados é local (SQLite) e os dados são armazenados no dispositivo
- O projeto está configurado para Android, iOS, Web, Windows e Linux
- Certifique-se de ter pelo menos 2GB de espaço livre para o Flutter e dependências

## 🆘 Precisa de ajuda?

Se encontrar problemas:

1. Execute `flutter doctor -v` para diagnóstico detalhado
2. Verifique a documentação oficial do Flutter: https://docs.flutter.dev/
3. Consulte os logs de erro no terminal

---

**Desenvolvido com Flutter** 🚀
