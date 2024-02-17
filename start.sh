#!/bin/bash
source <(curl -s https://raw.githubusercontent.com/itrocket-team/testnet_guides/main/utils/common.sh)

printLogo

#read -p "Enter WALLET name:" WALLET
$WALLET='wallet'
echo 'export WALLET='$WALLET
read -p "Enter your MONIKER :" MONIKER
echo 'export MONIKER='$MONIKER
$PORT='26'
#read -p "Enter your PORT (for example 17, default port=26):" PORT
echo 'export PORT='$PORT

# set vars
echo "export WALLET="$WALLET"" >> $HOME/.bash_profile
echo "export MONIKER="$MONIKER"" >> $HOME/.bash_profile
echo "export BABYLON_CHAIN_ID="bbn-test-2"" >> $HOME/.bash_profile
echo "export BABYLON_PORT="$PORT"" >> $HOME/.bash_profile
source $HOME/.bash_profile

printLine
echo -e "Moniker:        \e[1m\e[32m$MONIKER\e[0m"
echo -e "Wallet:         \e[1m\e[32m$WALLET\e[0m"
echo -e "Chain id:       \e[1m\e[32m$BABYLON_CHAIN_ID\e[0m"
echo -e "Node custom port:  \e[1m\e[32m$BABYLON_PORT\e[0m"
printLine
sleep 1

printGreen "1. Installing go..." && sleep 1
# install go, if needed
cd $HOME
VER="1.20.3"
wget "https://golang.org/dl/go$VER.linux-amd64.tar.gz"
sudo rm -rf /usr/local/go
sudo tar -C /usr/local -xzf "go$VER.linux-amd64.tar.gz"
rm "go$VER.linux-amd64.tar.gz"
[ ! -f ~/.bash_profile ] && touch ~/.bash_profile
echo "export PATH=$PATH:/usr/local/go/bin:~/go/bin" >> ~/.bash_profile
source $HOME/.bash_profile
[ ! -d ~/go/bin ] && mkdir -p ~/go/bin

echo $(go version) && sleep 1

source <(curl -s https://raw.githubusercontent.com/itrocket-team/testnet_guides/main/utils/dependencies_install)

printGreen "4. Installing binary..." && sleep 1
# download binary
cd $HOME
rm -rf babylon
git clone https://github.com/babylonchain/babylon.git
cd babylon
git checkout v0.7.2
make install

printGreen "5. Configuring and init app..." && sleep 1
# config and init app
babylond config node tcp://localhost:${BABYLON_PORT}657
babylond config keyring-backend os
babylond config chain-id bbn-test-2
babylond init $MONIKER --chain-id $BABYLON_CHAIN_ID
sed -i -e "s/^timeout_commit *=.*/timeout_commit = \"10s\"/" $HOME/.babylond/config/config.toml
sleep 1
echo done

printGreen "6. Downloading genesis and addrbook..." && sleep 1
# download genesis and addrbook
wget -O $HOME/.babylond/config/genesis.json https://testnet-files.itrocket.net/babylon/genesis.json
wget -O $HOME/.babylond/config/addrbook.json https://testnet-files.itrocket.net/babylon/addrbook.json
sleep 1
echo done

printGreen "7. Adding seeds, peers, configuring custom ports, pruning, minimum gas price..." && sleep 1
# set seeds and peers
SEEDS="cf36fd32c32e0bb89682e8b8e82c03049a0f0121@babylon-testnet-seed.itrocket.net:32656"
PEERS="857edc09e3371e9da3ef9336da535f3d880ca43e@164.68.121.169:16456,af1dcd33aa2f67d6f7b5f6ce9062febd99590a48@154.42.7.74:26656,59e8dad44f964821186962c60b5f2ac70585b31c@154.42.7.186:26656,4354f57e6d0c8edee46adf4affa96313eb62c0bf@154.42.7.161:26656,e9a352f36a1551071b05b48fc12a1005584515b1@194.163.180.43:16456,1a513dee45e7d3f5c9ea048db74503c79d874ed0@154.42.7.185:26656,0cbbae0cfd1c4bace50c54a50f7300ca996dd0ae@65.21.200.161:24656,55f235c372ab1a4253d52c26afbef5ef59cd62d6@37.60.228.189:26656,de438e7af12688447e16b822296f6d24044dcc5b@154.42.7.118:26656,bcb16afc39056faa22692f1faf3d057bf7ea08fa@154.42.7.200:26656,09b2c0f33112f6426b81c3dabe5e714895e0200b@154.12.237.118:26656,1273157000a471bad43020bfb8a1072e6dce23f4@89.117.51.133:16456,057373fc124765805d176e3c41b791518aab9b4e@194.163.167.48:26656,b74e574ccd37f839bad9c429e254f2d5f8696a1d@95.164.17.211:16456,d0402f3e1945286de769b0b963e7e3844eff07a2@65.109.118.162:16456,793d5a43d401ab3cd4c342814dfc0494ac47c1ec@89.117.49.94:16456,b5fa6e244a1c043bc5d69962025383401edb2bcd@161.97.105.45:16456,59ddc95451f1adc83a357144bd6207c297d20866@43.131.249.58:16456,4a9de9059445a66f4a333e57c2ed228e850b7765@5.189.167.29:16456,159992d8343b4ded1306fb3b36c861b52732cff1@43.155.160.234:16456,29a3e98d94d772d29023a6de3c943f7113226984@173.249.14.60:16456,78006719f5edc7da96f4c751bb9c260708a04cc3@158.220.97.112:16456,100a0aac14482f52ff2328629720b8c8bc15c867@38.242.255.128:16456,979d8e10811fb97726b716eb33c715e07cfa151a@84.247.183.225:20656,358d8b8093c5dd3aba04e4fb55d642531ff865bb@89.185.85.131:26656,c23b8b66290e8dc89f38d7ce4066fc1eb65c75dc@144.91.71.142:26656,0413dcbb53b3f16696fee8bf0f9f022b349e570a@38.242.222.95:26656,d626e8c8968be1acec7e23ef717e7b0654e56508@147.45.71.107:16456,528ff5cdc2c0b33775f24e23cb696cf9f570622e@161.97.146.140:656,8f19bdc9b82327d5fe53d52dacc57bb201228971@43.155.184.15:16456,a33dc2f8688905e7e29fd8e39f3e35a66ac29a59@194.195.87.172:16456,6c74452d61043055b67051514c6c628fa10854ec@167.86.71.23:26656,d9cff057243dae458123410565ad8b975d7a9098@103.164.54.230:656,07e51e02690608643505e7f34b414f4be404ede9@185.225.232.35:26656,b0b99a194efdf3248b9b808150090fe1de073568@144.91.94.238:26656,59801b2bc974ab91392360cdb4555814cec525c4@46.250.233.243:16456,543ebc3691bf5e9669972d5cf37a53311f490974@185.208.206.89:16456,6778d46ed5ba2e45efa3f8985a65b6fe1c00834a@84.247.166.43:26656,3cca8815a7ffac395a7be61ee475a20e89e5724e@194.233.69.13:656,fa5f2d0aee21a347189f94b1e175c425a62c9ee7@173.212.201.137:16456,458710e91118e6aac9fa9f11c948917856e4d8f4@5.252.22.195:16456,71d1c3a9401f7b7c40c331ad314f1a29e097f116@194.163.188.139:16456,ccbc596ca986f45eb32d45b47c46c7300a1064dc@154.42.7.49:26656,48af7f6c01be3268f3d5e8eace67a4d1b0e50fc5@194.146.13.254:16456,c0f205f22c1ae93498f0450ebbdd58d75eeb2734@24.199.106.250:20656,ea8f20471debfe6ee75d377ce52bf3acfad3202d@193.38.54.83:26656,2acab2ec47cf74c08837e80397385fda71aeac2c@109.205.180.179:16456,245948841f27ad237f21b32fa5c6f28516690039@154.42.7.64:26656,a827269b5ff40b12bf05f6289172e1c818b9a3a0@119.28.162.65:16456,46724f9d509f456b34efae9a101f878e7029e5f4@150.109.246.23:16456,ab2f4f7f618693c01e7aab6a45c6eb1b51dd3745@154.42.7.88:26656,4817a21e8a61639381a7c7249f4f243eedeedfc2@194.163.181.139:16456,338aca8acb57fa3a4600bc382478570e10ce70db@43.155.164.2:16456,4a13ce7ce1ceaa527310ffae4fa0b5e9e09d703d@154.42.7.198:26656,4a0f33e251c06cd9a5f47f20a135eb6f0a9f7c5d@95.111.241.180:16456,69e788079f7bc04f6018e67fb56ffa4d47afa680@129.226.220.243:16456"
sed -i -e "s/^seeds *=.*/seeds = \"$SEEDS\"/; s/^persistent_peers *=.*/persistent_peers = \"$PEERS\"/" $HOME/.babylond/config/config.toml

# set custom ports in app.toml
sed -i.bak -e "s%:1317%:${BABYLON_PORT}317%g;
s%:8080%:${BABYLON_PORT}080%g;
s%:9090%:${BABYLON_PORT}090%g;
s%:9091%:${BABYLON_PORT}091%g;
s%:8545%:${BABYLON_PORT}545%g;
s%:8546%:${BABYLON_PORT}546%g;
s%:6065%:${BABYLON_PORT}065%g" $HOME/.babylond/config/app.toml


# set custom ports in config.toml file
sed -i.bak -e "s%:26658%:${BABYLON_PORT}658%g;
s%:26657%:${BABYLON_PORT}657%g;
s%:6060%:${BABYLON_PORT}060%g;
s%:26656%:${BABYLON_PORT}656%g;
s%^external_address = \"\"%external_address = \"$(wget -qO- eth0.me):${BABYLON_PORT}656\"%;
s%:26660%:${BABYLON_PORT}660%g" $HOME/.babylond/config/config.toml

# config pruning
sed -i -e "s/^pruning *=.*/pruning = \"custom\"/" $HOME/.babylond/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"100\"/" $HOME/.babylond/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"50\"/" $HOME/.babylond/config/app.toml

# set minimum gas price, enable prometheus and disable indexing
sed -i 's|minimum-gas-prices =.*|minimum-gas-prices = "0.00001ubbn"|g' $HOME/.babylond/config/app.toml
sed -i -e "s/prometheus = false/prometheus = true/" $HOME/.babylond/config/config.toml
sed -i -e "s/^indexer *=.*/indexer = \"null\"/" $HOME/.babylond/config/config.toml
sleep 1
echo done

# create service file
sudo tee /etc/systemd/system/babylond.service > /dev/null <<EOF
[Unit]
Description=babylon node
After=network-online.target
[Service]
User=$USER
WorkingDirectory=$HOME/.babylond
ExecStart=$(which babylond) start --home $HOME/.babylond
Restart=on-failure
RestartSec=5
LimitNOFILE=65535
[Install]
WantedBy=multi-user.target
EOF

printGreen "8. Downloading snapshot and starting node..." && sleep 1
# reset and download snapshot
babylond tendermint unsafe-reset-all --home $HOME/.babylond
if curl -s --head curl https://testnet-files.itrocket.net/babylon/snap_babylon.tar.lz4 | head -n 1 | grep "200" > /dev/null; then
  curl https://testnet-files.itrocket.net/babylon/snap_babylon.tar.lz4 | lz4 -dc - | tar -xf - -C $HOME/.babylond
    else
  echo no have snap
fi

# enable and start service
sudo systemctl daemon-reload
sudo systemctl enable babylond
sudo systemctl restart babylond && sudo journalctl -u babylond -f
