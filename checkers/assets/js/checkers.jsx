import React from 'react';
import ReactDOM from 'react-dom';
import { Button } from 'reactstrap';

export default function game_init(root, channel) {
  ReactDOM.render(<CheckersGame channel={channel} />, root);
}


class CheckersGame extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      p1: null,
      p2: null,
      light_s: [],
      light_k: [],
      dark_s: [],
      dark_k: [],
      moves: [],
      current_player: "dark",
      checker_selected: -1,
      jump: false,
      winner: null,
      observers: [],
    };
    this.role = null;
    this.game = null;
    this.channel = props.channel;
	this.channel.join()
        .receive("ok", this.joinView.bind(this))
        .receive("error", resp => {console.log("Unable to join game.", resp)});
        
    this.channel.on("shout", payload => (this.setState(payload)));
  }
  
  get_observers(){
  	return this.state.observers;
  }
  
  get_winner(){
  	return this.state.winner;
  }
  
  get_player1(){
  	return this.state.p1;
  }
  
  get_player2(){
  	return this.state.p2;
  }
  
  get_current_player(){
  	return this.state.current_player;
  }
  
  get_light_soldiers(){
  	return this.state.light_s;
  }
  
  get_light_kings(){
  	return this.state.light_k;
  }
  
  get_dark_soldiers(){
  	return this.state.dark_s;
  }
  
  get_dark_kings(){
  	return this.state.dark_k;
  }
  
  get_moves(){
  	return this.state.moves;
  }
  
  get_sel_checker(){
  	return this.state.checker_selected;
  }
  
  joinView(payload){
  	this.game = payload[name];
  	this.role = payload.role;
  	console.log("New view", payload);
    	this.setState(payload.game);
  }
	
  gotView(view){
  	console.log("New view" , view);
	this.setState(view.game);
  }
	
  clicked(tileID){
  	this.channel.push("click",{tileID: tileID},)
	  .receive("ok",this.gotView.bind(this));
  }
  
  gotView(view) {
	console.log("New view", view);
    this.setState(view.game);
  }
  
  clicked(tileID){
  	this.channel.push("click",{tileID: tileID},)
  		.receive("ok", this.gotView.bind(this));
  }
  
  surrender(ev) {
  	if(this.role == "dark" || this.role == "light"){
  		this.channel.push("surrender",{role: this.role},)
  			.receive("ok", this.gotView.bind(this));
  	}
  }
  
  exit_lobby(ev) {
  	if (confirm("Do you want to exit this game??")) {
    	document.location.href = "/gamename";
	}
  }
  
  render(){
  	if(this.state.winner != null)
  		return(<div className="text-center"><Win root={this}/><br/><Exit root={this.exit_lobby.bind(this)}/>
  			</div>);
  	else if(this.state.p1 == null || this.state.p2 == null)
  		return(<div><Wait root={this}/>
  			<br/><div className="text-center"><Exit root={this.exit_lobby.bind(this)}/>
  			</div></div>);
  	else
  		return(
  			<div className="row">
    			<div className="col-sm-auto">
    				<Turn root={this}/>
    				<RenderBoard root={this}/>
    			</div>
    			<div className="col-sm-auto">
    				<div><br/></div>				
    				<div className="row">
    					<div className="col-sm-auto">
    						<GameBoard root={this}/>
    					</div>
    					<div className="col-sm-auto">
    						<Observers root={this}/>
    					</div>
    				</div>
    				<br/><br/>
    				<div className="row">
    					<div className="col-sm-auto">
    						<Surrender game={this.surrender.bind(this)}/>
    					</div>
    					<div className="col-sm-auto">
    						<Exit root={this.exit_lobby.bind(this)}/>
    					</div>
    				</div>
    			</div>
    		</div>
  		);
  }
}

function Wait(params){
	let root=params.root;
	let wait="";
	if(root.role=="observer") {
		wait="Waiting for players to join...";
	}
	else {
		wait="Waiting for another player to join...";
	}
	return (<h4 className="name text-center">{wait}</h4>);
}

function RenderBoard(params){
	console.log("Rendering Board");
	let root = params.root;
	let tiles=[]
	for(let i=0; i<64; i++)
	{
		let tile_id = i;
		let color = ((Math.floor(i/8)%2) == (Math.floor(i%8)%2))?"dark":"light";
		if (color == "dark"){
			let sc = "";
			if (root.get_sel_checker() == i){
				sc = " selected"			
			}
		
			if (root.get_dark_soldiers().includes(i)){
				if (root.get_moves().includes(i)){
					tiles.push(<div id={tile_id} key={i} className="dark_tile move" onClick={selectTile.bind(this, i, params)}>
						<div id={"c_"+tile_id} key={"c_"+tile_id} className={"dark"+sc} onClick={selectChecker.bind(this, i, params)}>
						</div></div>);
				}
				else{
					tiles.push(<div id={tile_id} key={i} className="dark_tile">
						<div id={"c_"+tile_id} key={"c_"+tile_id} className={"dark"+sc} onClick={selectChecker.bind(this, i, params)}>
						</div></div>);
				}
			}
			else if (root.get_dark_kings().includes(i)){
				if (root.get_moves().includes(i)){
					tiles.push(<div id={tile_id} key={i} className="dark_tile move" onClick={selectTile.bind(this, i, params)}>
						<div id={"c_"+tile_id} key={"c_"+tile_id} className={"dark"+sc} onClick={selectChecker.bind(this, i, params)}>
							K
						</div></div>)
				}
				else{			
					tiles.push(<div id={tile_id} key={i} className="dark_tile">
						<div id={"c_"+tile_id} key={"c_"+tile_id} className={"dark"+sc} onClick={selectChecker.bind(this, i, params)}>
							K
						</div></div>)
				}
			}
			else if (root.get_light_soldiers().includes(i)){
				if (root.get_moves().includes(i)){
					tiles.push(<div id={tile_id} key={i} className="dark_tile move" onClick={selectTile.bind(this, i, params)}>
						<div id={"c_"+tile_id} key={"c_"+tile_id} className={"light"+sc} onClick={selectChecker.bind(this, i, params)}>
						</div></div>)
				}
				else{
					tiles.push(<div id={tile_id} key={i} className="dark_tile">
						<div id={"c_"+tile_id} key={"c_"+tile_id} className={"light"+sc} onClick={selectChecker.bind(this, i, params)}>
						</div></div>)
				}
			}
			else if (root.get_light_kings().includes(i)){
				if (root.get_moves().includes(i)){
					tiles.push(<div id={tile_id} key={i} className="dark_tile move" onClick={selectTile.bind(this, i, params)}>
						<div id={"c_"+tile_id} key={"c_"+tile_id} className={"light"+sc} onClick={selectChecker.bind(this, i, params)}>
							K
						</div></div>)
				}
				else{
					tiles.push(<div id={tile_id} key={i} className="dark_tile">
						<div id={"c_"+tile_id} key={"c_"+tile_id} className={"light"+sc} onClick={selectChecker.bind(this, i, params)}>
							K
						</div></div>)
				}
			}	
			else{
				if (root.get_moves().includes(i)){
					tiles.push(<div id={tile_id} key={i} className="dark_tile move" onClick={selectTile.bind(this, i, params)}></div>)
				}
				else{
					tiles.push(<div id={tile_id} key={i} className="dark_tile"></div>)
				}	
			}
		}
		else{
			tiles.push(<div id={tile_id} key={i} className="light_tile"></div>)
		}	
	}	
	return <div key="board" id="board"> {tiles} </div>;
}

function selectTile(tileID, params){
	let root = params.root;
	
	if((root.get_sel_checker() != -1) && (root.get_current_player() == root.role)){
		root.clicked(tileID);
	}
}

function selectChecker(tileID, params){
	let root = params.root;
	let checkerID = "c_"+tileID;
	if((document.getElementById(checkerID).className == root.role) && (root.get_current_player() == root.role)){
		root.clicked(tileID);
	}
}

function Turn(params){
	let root = params.root;
	let turn = "";	
	if(root.role == root.get_current_player())
		turn = "Your turn...";
	else if(root.role == "dark")
		turn = "Player 2 is playing...";
	else if(root.role == "light")
		turn = "Player 1 is playing...";
	else{
		if(root.get_current_player() == "dark")
			turn = "Player 1 is playing...";
		else
			turn = "Player 2 is playing...";
	}
	return <div className="turn">{turn}</div>;
}

function Surrender(params){
	return (<button className="btn btn-dark btn-floating btn-lg" onClick={params.game}>
    			<span className="bts">SURRENDER</span>
  			</button>);
}

function Exit(params){
	return (<button className="btn btn-dark btn-floating btn-lg" onClick={params.root}>
    			<span className="bts">EXIT LOBBY</span>
  			</button>);
}


function GameBoard(params){
	let root=params.root; 
	let role="";
	if(root.role=="dark") {role="You're Player1(Black)."}
	else if(root.role=="light") {role="You're Player2(Red)."}
	else {role="You're a spectator."}
	return (<div className="card gameboard">
	<div className="card-body">
		<div className="card-title bts"> GameBoard: </div>
		<h5 className="card-subtitle mb-2">{role}</h5><br/><br/>
		<div className="row">
			<div className="col">
				<div id="c_dark" key="c_dark" className={"dark"}>
					{12 - root.get_dark_soldiers().length - root.get_dark_kings().length}	
				</div>
				<span className="name text-center"> Player 1: {root.get_player1()} </span>
			</div>
			<div className="col">
				<div id="c_light" key="c_light" className={"light"}>
					{12 - root.get_light_soldiers().length - root.get_light_kings().length}
				</div>
				<span className="name text-center"> Player 2: {root.get_player2()} </span>
			</div>
		</div>
	</div></div>);
}

function Observers(params){
	let root=params.root; 
	let spectators=root.get_observers();
	let list=[];
	
	for(let i=0; i<spectators.length; i++)
	{
		list.push(<li key={"ob_"+i}>{spectators[i]}</li>);	
	}
		
	return (<div className="card observer">
	<div className="card-body">
		<div className="card-title bts"> Spectators: </div>
		<ul className="obs-list">
			{list}
		</ul>
	</div></div>);
}

function Win(params){
	let winner: "";
	let root = params.root;
	console.log(root.get_winner())
	if(root.get_winner()=="dark")
		winner=root.get_player1();
	else
		winner=root.get_player2();
	
	return(<div className="winbox">
		<div className="text-center winner"> {winner} won... </div><br/>
		<span className="text-right">Please exit lobby and start a new game.</span>
		</div>);
}




