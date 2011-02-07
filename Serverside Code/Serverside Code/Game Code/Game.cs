using System;
using System.Collections.Generic;
using System.Text;
using System.Collections;
using PlayerIO.GameLibrary;
using System.Drawing;

namespace DrawPad
{
    //Player class. each player that join the game will have these attributes.
    public class Player : BasePlayer
    {
        public int playerIndex;
        public int playerX = 200;
        public int PlayerY = 200;
    }

    [RoomType("Crawler")]
    public class GameCode2 : Game<Player>
    {
        private int numPlayers = 0;
        private int levelSeed = 10;
        public override void GameStarted()
        {
            // anything you write to the Console will show up in the 
            // output window of the development server
            //Random rnd = new Random();
            //levelSeed = rnd.Next(0, 60000);
            Console.WriteLine("Crawler game has started");
        }

        // This method is called when the last player leaves the room, and it's closed down.
        public override void GameClosed()
        {
            Console.WriteLine("Crawler RoomId: " + RoomId + " has closed.");
        }
        public override bool AllowUserJoin(Player player)
        {
            if (numPlayers >= 4)
            {
                return false;
            }
            else
            {
                return base.AllowUserJoin(player);
            }
        }
        // This method is called whenever a player joins the game
        public override void UserJoined(Player player)
        {
            player.playerIndex = 0;
            int PI = 0;
            int numInstances = 0;
            Boolean temp = false;
            do
            {
                temp = false;
                numInstances = 0;
                foreach (Player p in Players)
                {
                    if (p.playerIndex == PI)
                    {
                        numInstances++;
                    }
                }
                if (numInstances > 1)
                {
                    player.playerIndex++;
                    PI++;
                    temp = true;
                }
            } while (temp == true);
            player.playerIndex = PI;
            //Send info about all already connected users to the newly joined users chat
            Message m = Message.Create("GameInit");
            m.Add(player.playerIndex, levelSeed);

            foreach (Player p in Players)
            {
                m.Add(p.playerIndex, p.ConnectUserId, p.playerX, p.PlayerY);
            }

            player.Send(m);

            //Informs other users chats that a new user just joined.
            Broadcast("GameJoin", player.playerIndex, player.ConnectUserId);
            numPlayers++;
        }

        // This method is called when a player leaves the game
        public override void UserLeft(Player player)
        {
            //Tell the chat that the player left.
            Broadcast("GameLeft", player.playerIndex);
            numPlayers--;
        }

        // This method is called when a player sends a message into the server code
        public override void GotMessage(Player player, Message message)
        {
            switch (message.Type)
            {
                case "start":
                    {
                        Broadcast("start", player.Id, player.ConnectUserId, message.GetInt(0), message.GetInt(1));
                        break;
                    }
                case "stop":
                    {
                        Broadcast("stop", player.Id);
                        break;
                    }
                case "move":
                    {
                        player.playerX = message.GetInt(0);
                        player.PlayerY = message.GetInt(1);
                        Broadcast("move", player.playerIndex, message.GetInt(0), message.GetInt(1), message.GetInt(2), message.GetInt(3));
                        break;
                    }
                case "ChatMessage":
                    {
                        Broadcast("ChatMessage", player.Id, message.GetString(0));
                        break;
                    }
            }
        }
    }

    [RoomType("DrawPad")]
    public class GameCode : Game<Player>
    {
        // This method is called when an instance of your the game is created
        public override void GameStarted()
        {
            // anything you write to the Console will show up in the 
            // output window of the development server
            Console.WriteLine("Game is started");
        }

        // This method is called when the last player leaves the room, and it's closed down.
        public override void GameClosed()
        {
            Console.WriteLine("RoomId: " + RoomId);
        }

        // This method is called whenever a player joins the game
        public override void UserJoined(Player player)
        {

            //Send info about all already connected users to the newly joined users chat
            Message m = Message.Create("ChatInit");
            m.Add(player.Id);

            foreach (Player p in Players)
            {
                m.Add(p.Id, p.ConnectUserId);
            }

            player.Send(m);

            //Informs other users chats that a new user just joined.
            Broadcast("ChatJoin", player.Id, player.ConnectUserId);
        }

        // This method is called when a player leaves the game
        public override void UserLeft(Player player)
        {
            //Tell the chat that the player left.
            Broadcast("ChatLeft", player.Id);
        }

        // This method is called when a player sends a message into the server code
        public override void GotMessage(Player player, Message message)
        {
            switch (message.Type)
            {
                case "start":
                    {
                        Broadcast("start", player.Id, player.ConnectUserId, message.GetInt(0), message.GetInt(1));
                        break;
                    }
                case "stop":
                    {
                        Broadcast("stop", player.Id);
                        break;
                    }
                case "move":
                    {
                        Broadcast("move", player.Id, message.GetInt(0), message.GetInt(1));
                        break;
                    }
                case "ChatMessage":
                    {
                        Broadcast("ChatMessage", player.Id, message.GetString(0));
                        break;
                    }
            }
        }
    }
}