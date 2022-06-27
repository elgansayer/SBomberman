// using Godot;
// using Newtonsoft.Json;
// using System;
// using System.Collections.Generic;

// namespace Network
// {

//     public partial class GameState : Node2D
//     {
//         public readonly Dictionary<int, PeerInfo> Peers = new Dictionary<int, PeerInfo>();

//         [JsonIgnore]
//         public string SnapShot
//         {
//             get => this.ToJson();
//             set => this.SetSnapshot(value);
//         }

//         public string ToJson()
//         {
//             return JsonConvert.SerializeObject(this.Peers);
//         }

//         internal void SetSnapshot(string gameStateSnapshot)
//         {
//             Dictionary<int, PeerInfo> peerData = JsonConvert.DeserializeObject<Dictionary<int, PeerInfo>>(gameStateSnapshot);
//             foreach (KeyValuePair<int, PeerInfo> peerInfo in peerData)
//             {
//                 this.Peers[peerInfo.Key] = peerInfo.Value;
//             }
//         }

//         public override void _Ready()
//         {
//             GD.Print("GameState Ready");
//             this.RpcConfig(nameof(this.RegisterPeer), RPCMode.AnyPeer, true, TransferMode.Reliable);
//         }

//         // Called when the node enters the scene tree for the first time.
//         public void AddPeer(PeerInfo peerInfo)
//         {
//             this.Peers.Add(peerInfo.Id, peerInfo);
//         }

//         public PeerInfo AddPeer(int peerId)
//         {
//             PeerInfo peerInfo = new PeerInfo();
//             peerInfo.Id = peerId;
//             this.Peers.Add(peerId, peerInfo);
//             return peerInfo;
//         }

//         public bool RemovePeer(PeerInfo peerInfo)
//         {
//             return this.Peers.Remove(peerInfo.Id);
//         }

//         public bool RemovePeer(int peerId)
//         {
//             return this.Peers.Remove(peerId);
//         }

//         internal void UpdatePeer(PeerInfo peerInfo)
//         {
//             this.Peers[peerInfo.Id].UpdatePeer(peerInfo);
//         }

//         [Authority]
//         [AnyPeer]
//         public void RegisterPeer(string peerData)
//         {
//             GD.Print("GameState Register Player");

//             PeerInfo peerInfo = JsonConvert.DeserializeObject<PeerInfo>(peerData);
//             peerInfo.State = PeerInfoState.Registered;
//             int peerId = peerInfo.Id;

//             this.UpdatePeer(peerInfo);

//             GD.Print(what: "Added peer with id: " + peerId);

//             if (Multiplayer.IsServer())
//             {
//                 // Update Rocks
//                 this.UpdatePeers();
//             }
//         }

//         public void UpdatePeers()
//         {
//             // return;
//             // Send the snapshot to all clients
//             this.Rpc(nameof(this.RecievedSnapshot), this.SnapShot);
//         }

//         [AnyPeer]
//         private void RecievedSnapshot(string battleSnapShotJson)
//         {
//             this.SnapShot = battleSnapShotJson;
//         }

//     }
// }