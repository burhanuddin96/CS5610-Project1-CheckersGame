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
    this.channel = props.channel;
	this.channel.join()
        .receive("ok", this.joinView.bind(this))
        .receive("error", resp => {console.log("Unable to join game.", resp)});
        
    this.channel.on("shout", payload => (this.setState(payload)));
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
  	this.channel.push("resetGame",{},)
  		.receive("ok", this.gotView.bind(this));
  }
  
  render(){
  	if(this.state.p1 == null || this.state.p2 == null)
  		return(<div className="name text-center"><h4>Waiting For Another Player...</h4></div>);
  	else
  		return(
  			<div className="row justify-content-md-center">
    			<div className="col">
    				<Turn root={this}/>
    				<RenderBoard root={this}/>
    			</div>
    			<div className="col a">				
    			</div>
    			<div className="col">
    				<div className="row surrender-p">
    				<Surrender game={this.surrender.bind(this)}/>
    				</div> 
    			</div>
    		</div>
  		);
  }
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
		turn = "It's your turn...";
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
	return (<div className="surrender-c text-center" onClick={params.game}>
    			<p>SURRENDER</p>
  			</div>);
}





