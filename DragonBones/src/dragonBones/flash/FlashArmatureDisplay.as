package dragonBones.flash
{
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.utils.getTimer;
	
	import dragonBones.Armature;
	import dragonBones.Bone;
	import dragonBones.animation.Animation;
	import dragonBones.animation.WorldClock;
	import dragonBones.core.IArmatureDisplay;
	import dragonBones.core.dragonBones_internal;
	import dragonBones.events.EventObject;
	
	use namespace dragonBones_internal;
	
	/**
	 * @inheritDoc
	 */
	public class FlashArmatureDisplay extends Sprite implements IArmatureDisplay
	{
		private static const _enterFrameHelper:Shape = new Shape();
		private static const _clock:WorldClock = new WorldClock();
		private static function _clockHandler(event:Event):void 
		{
			const time:Number = getTimer() * 0.001;
			const passedTime:Number = time - _clock.time;
			_clock.advanceTime(passedTime);
			_clock.time = time;
		}
		
		/**
		 * @private
		 */
		dragonBones_internal var _armature:Armature;
		
		private var _debugDrawer:Shape;
		
		/**
		 * @private
		 */
		public function FlashArmatureDisplay()
		{
			super();
			
			if (!_enterFrameHelper.hasEventListener(Event.ENTER_FRAME))
			{
				_clock.time = getTimer() * 0.001;
				_enterFrameHelper.addEventListener(Event.ENTER_FRAME, _clockHandler, false, -999999);
			}
		}
		
		/**
		 * @inheritDoc
		 */
		public function _onClear():void
		{
			_armature = null;
			_debugDrawer = null;
		}
		
		/**
		 * @inheritDoc
		 */
		public function _dispatchEvent(eventObject:EventObject):void
		{
			const event:FlashEvent = new FlashEvent(eventObject.type, eventObject);
			
			this.dispatchEvent(event);
		}
		
		/**
		 * @inheritDoc
		 */
		public function _debugDraw():void
		{
			if (!_debugDrawer) 
			{
				_debugDrawer = new Shape();
			}
			
			this.addChild(_debugDrawer);
			_debugDrawer.graphics.clear();
			
			const bones:Vector.<Bone> = _armature.getBones();
			for (var i:uint = 0, l:uint = bones.length; i < l; ++i) 
			{
				const bone:Bone = bones[i];
				const boneLength:Number = Math.max(bone.length, 5);
				const startX:Number = bone.globalTransformMatrix.tx;
				const startY:Number = bone.globalTransformMatrix.ty;
				const endX:Number = startX + bone.globalTransformMatrix.a * boneLength;
				const endY:Number = startY + bone.globalTransformMatrix.b * boneLength;
				
				_debugDrawer.graphics.lineStyle(1, bone.ik ? 0xFF0000 : 0x00FF00, 0.5);
				_debugDrawer.graphics.moveTo(startX, startY);
				_debugDrawer.graphics.lineTo(endX, endY);
			}
		}
		
		/**
		 * @inheritDoc
		 */
		public function hasEvent(type:String):Boolean
		{
			return this.hasEventListener(type);
		}
		
		/**
		 * @inheritDoc
		 */
		public function addEvent(type:String, listener:Function):void
		{
			this.addEventListener(type, listener);
		}
		
		/**
		 * @inheritDoc
		 */
		public function dispose():void
		{
			if (_armature)
			{
				advanceTimeBySelf(false);
				_armature.dispose();
				_armature = null;
			}
		}
		
		/**
		 * @inheritDoc
		 */
		public function removeEvent(type:String, listener:Function):void
		{
			this.removeEventListener(type, listener);
		}
		
		/**
		 * @inheritDoc
		 */
		public function advanceTimeBySelf(on:Boolean):void
		{
			if (on)
			{
				_clock.add(this._armature);
			} 
			else 
			{
				_clock.remove(this._armature);
			}
		}
		
		/**
		 * @inheritDoc
		 */
		public function get armature():Armature
		{
			return _armature;
		}
		
		/**
		 * @inheritDoc
		 */
		public function get animation():Animation
		{
			return _armature.animation;
		}
	}
}