# FlowAI

FlowAI é um plugin movimentação de IA baseado em Areas e PathNodes. Ele permite criar caminhos predefinidos para que a IA possa seguir, oferecendo flexibilidade para jogos com tráfego, pedestres, etc.

## Features
- Criação de PathNodes conectáveis entre si.
- Organização por Áreas, permitindo ativar/desativar regiões para otimizar o desempenho.
- Sistema de links entre nodes para gerar caminhos dinâmicos.
- Salvamento e carregamento de dados via JSON.

## Installation
- Baixe este repositorio e coloque esta pasta em `plugins/`.
- Vá em `Project Settings > Plugins``` e ative o FlowAI.
- Um novo nó `FlowAIController` ficará disponível para ser adicionado na cena principal.

## Usage
Adicionando e selecionando o `FlowAIController` na sua cena, no inspector vai aparecer alguns botões:
  - Save Data
  - Load Data
  - Add Area

Clicando em `Add Area`, vai ser adicionando uma nova area como filho do `FlowAIController`, que vai te permitir organizar seus pathnodes.

Com a Area selecionada, você vai conseguir ver um botão no Inspector chamado `Add Pathnode`. Com ele você pode criar Pathnodes que não estejam conectados com os outros. Você pode mover e fazer o que quiser com ele, pois ele será seu Pathnode inicial.

Com o pathnode selecionado, você terá acesso a algumas informações, como o `PathnodeID`, `AreaID` que é o ID da area no qual o pathnode faz parte, `Previous Pathnode` no qual eu vou explicar em breve e tambem vai ter acesso aos Pathnodes que estão linkados com o Pathnode selecionado. Você tambem terá acesso ao botão `Add Next Pathnode` onde você vai conseguir criar um novo pathnode se baseando no pathnode selecionado.

Quando você utiliza o `Add Next Pathnode`, você está criando um novo pathnode que vai receber a mesma posição e a mesma area do pathnode selecionado. Esse novo pathnode vai receber como valor no `Previous Pathnode` o pathnode que está selecionado.

> [!WARNING]
> Quando você finalizar o seu progresso, lembre-se de criar um arquivo json no seu projeto e setar o caminho dele no `FlowAIController`, na variavel `Data Path` e depois clicar no botão `Save Data` para que todos os dados do Plugin sejam salvos corretamente. Sei que não é nada intuitivo, mas não pensei em uma forma melhor de fazer isso ainda. Sempre que modificarem `FlowAIController` seja adicionando uma nova area ou um novo pathnode, `SALVEM OS DADOS`

Com todo os seus dados salvos, vamos criar nosso NPC!

## Roadmap
- [ ] 
