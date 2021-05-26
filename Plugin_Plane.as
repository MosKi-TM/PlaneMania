#name "Plane"
#author "Moski"
#category "Dev"
#perms "paid"

#include "utils.as"
#include "Plane_Phy.as"

Dev::HookInfo@ position_update;
PlanePhy@ plr_phy;
bool in_game = false;
uint64 dt;

uint64 position_update_addr;

enum Hotkeys {Accelerate, Up, Down, RollLeft, RollRight, YawLeft, YawRight, Jump};
bool[] Hotkey_List = {false,false,false,false,false,false,false, false};

float throttle_power = 40.0;
float roll_power = 0.5;
float yaw_power = 0.5;
float up_power = 0.5;

void OnDestroyed()
{
	Dev::Unhook(position_update);
	if(!toggle_physics())
		toggle_physics(); //enable velocity update again (broken)
}

void Main()
{
	position_update_addr = Dev::FindPattern(""); //A specific pattern
	if (position_update_addr != 0) 
		@position_update = Dev::Hook(position_update_addr, 1, "Position_update"); //Hook where the game update car's position

	toggle_physics(); //disable trackmania velocity update
}

void Position_update(CMwNod@ rbx)//called when the game update car's position
{	
	if(!in_game)
	{
		dt = Time::get_Now();
		@plr_phy = PlanePhy(rbx);	
		in_game = true;
	}

	Compute_Inputs(plr_phy, float(Time::get_Now() - dt)); //Compute input and apply basic Throttle, Yaw etc
	Compute_Phy(plr_phy, float(Time::get_Now() - dt)); //compute lift, drag, weight

	dt = Time::get_Now();//should be named last_time

}

void Render()
{

	if(plr_phy is null)
		return;
	
	//debug place to check variable (used for test)
	UI::Begin("Debug Window");
		UI::Text("Lift = " + plr_phy.lift);
		UI::Text("Drag = " + plr_phy.drag);
		UI::Text("velocity = " + format_vec3(plr_phy.velocity));
		UI::Text("rot velocity = " + format_vec3(plr_phy.rot_velocity));
		UI::Text("forward = " + format_vec3(plr_phy.forward));
		UI::Text("up = " + format_vec3(plr_phy.up));
		UI::Text("left = " + format_vec3(plr_phy.left));
		UI::Text("AoA = " + plr_phy.AoA);
		UI::Text("speed = " + plr_phy.speed);
		UI::Text("surface id = " + plr_phy.surface_id);
		UI::Text("Dt = " + dt);
	UI::End();
}

bool OnKeyPress(bool down, VirtualKey key) //Trigger Hotkey events
{
	if(key == VirtualKey::X)
		Hotkey_List[Hotkeys::Accelerate] = down;

	if(key == VirtualKey::K)
		Hotkey_List[Hotkeys::Up] = down;

	if(key == VirtualKey::I)
		Hotkey_List[Hotkeys::Down] = down;

	if(key == VirtualKey::Numpad4)
		Hotkey_List[Hotkeys::YawLeft] = down;

	if(key == VirtualKey::Numpad6)
		Hotkey_List[Hotkeys::YawRight] = down;

	if(key == VirtualKey::J)
		Hotkey_List[Hotkeys::RollLeft] = down;

	if(key == VirtualKey::L)
		Hotkey_List[Hotkeys::RollRight] = down;

	return true;
}

void Compute_Inputs(PlanePhy@ player, float dt)
{
    //Basic moves mapped on key, will be modified as force in Compute_Phy
    if(Hotkey_List[Hotkeys::Accelerate])
        plr_phy.velocity += plr_phy.forward*(dt/1000)*throttle_power;

    if(Hotkey_List[Hotkeys::Up])
        plr_phy.rot_velocity += (plr_phy.left*(-1.0))*(dt/1000)*up_power;

    if(Hotkey_List[Hotkeys::Down])
        plr_phy.rot_velocity +=  plr_phy.left*(dt/1000)*up_power;

    if(Hotkey_List[Hotkeys::YawLeft])
        plr_phy.rot_velocity += plr_phy.up*(dt/1000)*yaw_power;

    if(Hotkey_List[Hotkeys::YawRight])
        plr_phy.rot_velocity += (plr_phy.up*(-1.0))*(dt/1000)*yaw_power;

    if(Hotkey_List[Hotkeys::RollRight])
        plr_phy.rot_velocity += plr_phy.forward*(dt/1000)*roll_power; 
    
    if(Hotkey_List[Hotkeys::RollLeft])
        plr_phy.rot_velocity += (plr_phy.forward*(-1.0))*(dt/1000)*roll_power; 
}
