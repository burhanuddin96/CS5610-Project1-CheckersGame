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
      current_player: "P1",
      checker_selected: -1,
      jump: false,
      game_state: "wait_p",
    };
    this.role = null;
    this.channel = props.channel;
	this.channel.join()
        .receive("ok", this.joinView.bind(this))
        .receive("error", resp => {console.log("Unable to join game.", resp)});
  }
  
  joinView(view){
  	this.role = view.role;
  	console.log("New view", view);
    this.setState(view.game);
  }
  
  render(){
  	if(this.state.game_state == "wait_p")
  		return(<div><div> Player 1 = {this.state.p1}</div>
  			<div>Current User = {window.current_user}<br/>Role = {this.role}</div></div>
  		);
  	else
  		return(
  			<div> Both players in the lobby </div>	
  		);
  }
}
