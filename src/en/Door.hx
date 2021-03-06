package en;

class Door extends Entity {
	public static var ALL : Array<Door> = [];
	var data : Entity_Door;
	var cHei = 2;
	public var isClosed(default,null) : Bool;
	public var needKey : Bool;

	var willChangeWhenLeft = false;

	public function new(e:Entity_Door) {
		super(e.cx, e.cy);
		ALL.push(this);
		data = e;
		gravityMul = 0;
		needKey = data.f_needKey;
		darkMode = GoOutOfGame;
		setDefaultState();
		Game.ME.scroller.add(spr, Const.DP_BG);
	}

	public function setDefaultState() {
		setClosed( data.f_startClosed );
	}

	public function isInDefaultState() {
		return isClosed == data.f_startClosed;
	}

	public function setClosed(closed:Bool) {
		if( level==null || level.destroyed || !isAlive() )
			return;

		isClosed = closed;

		if( isClosed ) {
			sprScaleX = 1;
			setSquashX(0.7);
		}
		else
			setSquashY(0.7);

		if( spr!=null && !spr.destroyed )
			spr.set(needKey && data.f_showLock ? ( closed ? "doorKeyClosed" : "doorKeyOpen" ) : ( closed ? "doorClosed" : "doorOpen" ));

		for(i in 0...cHei)
			level.setExtraCollision(cx,cy-i, closed);
	}

	override function postUpdate() {
		super.postUpdate();
		if( !isClosed && isOutOfTheGame() )
			spr.visible = false;
	}

	override function dispose() {
		super.dispose();

		if( isClosed )
			setClosed(false);

		ALL.remove(this);
	}

	override function onDark() {
		super.onDark();
		willChangeWhenLeft = false;
	}

	override function update() {
		super.update();

		if( needKey && isClosed ) {
			for(e in en.Item.ALL) {
				if( !e.isAlive() || e.type!=DoorKey || !e.isGrabbedByHero() && !e.cd.has("recentThrow") )
					continue;

				if( !e.isGrabbedByHero() && distCase(e)<=1.4 || e.isGrabbedByHero() && distCase(e)<=1.2 ) {
					e.destroy();
					fx.doorOpen(footX, footY, hero.dirTo(this));
					sprScaleX = hero.dirTo(this);
					Assets.SLIB.door0(1);
					setClosed(false);
					game.popText(headX, headY, "Used key");
				}
			}
		}

		if( !game.dark && data.f_autoChangeWhenPassThrough ) {
			if( hero.cx==cx && ( hero.cy>=cy-1 && hero.cy<=cy ) ) {
				willChangeWhenLeft = true;
			}
			else if( willChangeWhenLeft && M.fabs(hero.cx-cx)>1 ) {
				willChangeWhenLeft = false;
				Assets.SLIB.door0(1);
				setClosed( !isClosed );
			}
		}
	}
}