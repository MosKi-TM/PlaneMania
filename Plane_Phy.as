class PlaneProperties
{
	float Cd0 = 0.0211; //value from similar caracteristics plane
    float Chord = 1.17;
    float Span = 7.28;
    float AR = Span/Chord;
    float effiency_coef = 0.7;
    float air_density = 1.293;
    float wing_surface = Chord*Span;
    float plane_mass = 1000.0;	
}

class CGamePlayerPhy
{
//Class that provide Car's Rotation,Position,Veloctiy and rotation velocity, those are variable.
//Provide also const like up,left and forward car's vector (directions).
}

class PlanePhy : CGamePlayerPhy
{

	PlaneProperties@ p_config = PlaneProperties();

	PlanePhy(CMwNod@ nod){super(nod);}

	float get_AoA(){
    	if((this.velocity.Length() * this.up.Length()) == 0) return 0;

    	else return 3.14/2 - (Math::Acos(
    		Math::Dot(this.up*-1.0,this.velocity)
    		/(this.velocity.Length() * this.up.Length())
    		)); //calculate the angle of attack between car rotation and car velocity direction
    }

    float get_speed(){return this.velocity.Length();}//get velocity vector's magnitude

    float get_Cl()	{if(this.AoA < Math::ToRad(25.0) && this.AoA > Math::ToRad(-5.0)) return 2*3.14*this.AoA;else return 0;}//lift coef calculation

    float get_Cd()	{return p_config.Cd0 + (this.Cl*this.Cl)/(3.14*p_config.AR*p_config.effiency_coef);} //Drag Coef calculation

    float get_lift(){return 0.5*this.Cl*p_config.air_density*(this.speed*this.speed)*p_config.wing_surface;}//Lift Calculation (unit: Newton)

    float get_drag(){return 0.5*this.Cd*p_config.air_density*(this.speed*this.speed)*p_config.wing_surface;}//Drag calculation (unit: Newton)
}

bool toggle_physics()
{
    //Function that disable velocity update from the game
}

void Compute_Phy(PlanePhy@ player, float dt)
{
    float weight_force= 9.81*player.p_config.plane_mass;
    vec3 Force_Sum = player.up*player.lift //applying lift on Y axis of the car
                    + (player.forward * -1.0) * player.drag //applying drag on -X of the car
                    + vec3(0.0,-1.0,0.0)*weight_force; //applying gravity force in World -Y

    vec3 delta_velocity = (Force_Sum/player.p_config.plane_mass) * (dt/1000); //Coming from Sum(F) = m * dv/dt

    player.velocity += delta_velocity;
}
