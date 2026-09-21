package UI.gaming
{
   import flash.ui.Multitouch;
   import flash.ui.MultitouchInputMode;
   import flash.system.Capabilities;
   import UI.login.HeadBtn;
   import data.StringToDefine;
   import flash.display.MovieClip;
   import flash.display.DisplayObject;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.events.TouchEvent;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import flash.text.TextField;
   import gameAll.data.ArmsItemsData;
   import gameAll.data.ArmsItemsDataGroup;
   import gameAll.data.GameData;
   import gameAll.data.challenge.ChallengeTaskDefine;
   import gameAll.data.collect.CollectTaskDefine;
   import gameAll.define.OneTaskDefine;
   import gs.TweenLite;
   import gs.easing.Back;
   import image.GameSprite;
   import net.SWFLoaderManager;
   
   public class GamingUI extends Sprite
   {
      
      public var nowSaveNum:int = 0;
      
      public var nowState:String = "";
      
      public var GD:GameData;
      
      private var _bossBarTarget:* = null;
      
      public var bossBarB:Boolean = false;
      
      public var w:Number = 950;
      
      public var h:Number = 560;
      
      public var swf:SWFLoaderManager;
      
      public var GS:GameSprite;
      
      public var _mc:*;
      
      public var _mc2:ArenaGamingUI;
      
      public var playerName_txt:TextField;
      
      public var head_btn:HeadBtn;
      
      public var time_txt:TextField;
      
      public var gcoin_txt:TextField;
      
      public var score_txt:TextField;
      
      public var hitRate_txt:TextField;
      
      public var hurtNum_txt:TextField;
      
      public var life_bar:LifeBar;
      
      public var energy_bar:LifeBar;
      
      public var exp_bar:LifeBar;
      
      public var boss_bar:LifeBar2;
      
      public var lv_txt:TextField;
      
      public var expTime_txt:TextField;
      
      public var testTxt:TextField;
      
      public var timeLimit_txt:TextField;
      
      public var task_mc:*;
      
      public var pointer:MovieClip;
      
      public var arms1:GamingArmsIcon;
      
      public var arms2:GamingArmsIcon;
      
      public var arms3:GamingArmsIcon;
      
      public var arms4:GamingArmsIcon;
      
      public var arms5:GamingArmsIcon;
      
      public var arms6:GamingArmsIcon;
      
      public var arms7:GamingArmsIcon;
      
      public var arms8:GamingArmsIcon;
      
      public var arms_icon:Array;
      
      public var arms_y:int = 0;
      
      public var testArr:Array = [];
      
      public var nowArmsType:Array = [3,0,0,0,0,0];
      
      public var skillBox:SkillIconBox;

      private var mobileControls:Sprite;

      private var moveBase:Sprite;

      private var moveKnob:Sprite;

      private var aimBase:Sprite;

      private var aimKnob:Sprite;

      private var attackButton:Sprite;

      private var moveTouchId:int = -1;

      private var aimTouchId:int = -1;

      private var attackTouchId:int = -1;

      private var mobileAttacking:Boolean = false;

      private var mobileAimActive:Boolean = false;

      private var mobileAimX:Number = 1;

      private var mobileAimY:Number = 0;

      private var moveDragStart:Point = new Point();

      private var aimDragStart:Point = new Point();

      private var moveKnobStart:Point = new Point();

      private var aimKnobStart:Point = new Point();

      private var moveRelativeDrag:Boolean = false;

      private var aimRelativeDrag:Boolean = false;

      private var mobileUITouches:Object = {};

      private var mobileSkillTouches:Object = {};

      private var mobileMoveSector:String = "center";

      private var mobileJumpDelayFrames:int = 0;

      private var mobileJumpCount:int = 0;
      private var mobileGravityInterval:int = 0;

      private var mobileGravityHeld:Boolean = false;

      private var mobileBattleModeActive:Boolean = false;

      private const JOYSTICK_RADIUS:Number = 76;

      private const ATTACK_RADIUS:Number = 38;
      
      public function GamingUI()
      {
         super();
         this.w = Game.stageWidth;
         this.h = Game.stageHeight;
      }
      
      public function init() : *
      {
         var i:* = undefined;
         var n:* = undefined;
         var name_Arr:Array = ["playerName_txt","head_btn","time_txt","gcoin_txt","score_txt","hitRate_txt","hurtNum_txt","life_bar","energy_bar","exp_bar","boss_bar","lv_txt","expTime_txt","testTxt","timeLimit_txt","task_mc","pointer"];
         for(i in name_Arr)
         {
            this[name_Arr[i]] = this._mc[name_Arr[i]];
         }
         this._mc2.visible = false;
         this.pointer.stop();
         this.pointer.visible = true;
         this.GS = Game.gameSprite;
         this.GD = Game.gameData;
         this.pointer.mouseChildren = false;
         this.pointer.mouseEnabled = false;
         this.arms_icon = [this.arms1,this.arms2,this.arms3,this.arms4,this.arms5,this.arms6,this.arms7,this.arms8];
         for(n in this.arms_icon)
         {
            this.arms_icon[n].numTxt.text = String(n + 1);
            this.arms_icon[n].setType(this.nowArmsType[n]);
         }
         this.boss_bar.visible = false;
         this.head_btn.goLabel("over");
         this.head_btn.mouseEnabled = false;
         this.testTxt.visible = false;
         this.task_mc.visible = false;
         this.timeLimit_txt.visible = false;
         this.skillBox = new SkillIconBox();
         addChild(this.skillBox);
         this.skillBox.x = 227;
         this.skillBox.y = 470;
         this.arms_y = this.arms1.y;
         this.fleshKeyLabels();
         this.initMobileControls();
      }

      private function initMobileControls() : void
      {
         if(!Multitouch.supportsTouchEvents)
         {
            return;
         }
         this.mobileControls = new Sprite();
         this.mobileControls.visible = false;
         // 移动摇杆只保留外圈，避免视觉上把可移动范围压缩成小环。
         this.moveBase = this.createJoystick(132,370,4473924,false);
         // 攻击摇杆保留提示内圈，但缩小为更容易覆盖的中心区。
         this.aimBase = this.createJoystick(828,370,16746496,true);
         this.moveKnob = this.createKnob(this.moveBase,4473924);
         this.aimKnob = this.createKnob(this.aimBase,16746496);
         this.attackButton = this.createAttackButton();
         this.mobileControls.addChild(this.moveBase);
         this.mobileControls.addChild(this.aimBase);
         this.mobileControls.addChild(this.attackButton);
         addChild(this.mobileControls);
         this.refreshMobileControlMode();
      }

      private function createAttackButton() : Sprite
      {
         var button:Sprite = new Sprite();
         button.x = 882;
         button.y = 255;
         button.graphics.lineStyle(3,16777215,0.9);
         button.graphics.beginFill(16746496,0.58);
         button.graphics.drawCircle(0,0,32);
         button.graphics.endFill();
         button.graphics.lineStyle(2,16777215,0.9);
         button.graphics.drawCircle(0,0,12);
         return button;
      }

      public function refreshMobileControlMode() : void
      {
         if(this.attackButton == null)
         {
            return;
         }
         var mode:String = this.getMobileAttackMode();
         this.attackButton.visible = mode == "stickButton" || mode == "touchButton";
      }

      private function getMobileMoveMode() : String
      {
         return Game.uiGroup != null && Game.uiGroup.allback != null ? Game.uiGroup.allback.getMobileMoveMode() : "halfScreen";
      }

      private function getMobileAttackMode() : String
      {
         return Game.uiGroup != null && Game.uiGroup.allback != null ? Game.uiGroup.allback.getMobileAttackMode() : "stickFire";
      }

      private function createJoystick(px:Number, py:Number, color:uint, showInner:Boolean) : Sprite
      {
         var base:Sprite = new Sprite();
         base.x = px;
         base.y = py;
         base.graphics.lineStyle(3,16777215,0.8);
         base.graphics.beginFill(0,0.22);
         base.graphics.drawCircle(0,0,this.JOYSTICK_RADIUS);
         base.graphics.endFill();
         if(showInner)
         {
            base.graphics.lineStyle(2,color,0.8);
            base.graphics.drawCircle(0,0,28);
         }
         return base;
      }

      private function createKnob(base:Sprite, color:uint) : Sprite
      {
         var knob:Sprite = new Sprite();
         knob.mouseEnabled = true;
         knob.graphics.lineStyle(2,16777215,0.9);
         knob.graphics.beginFill(color,0.5);
         knob.graphics.drawCircle(0,0,22);
         knob.graphics.endFill();
         base.addChild(knob);
         return knob;
      }

      public function enterMobileBattleMode() : void
      {
         if(this.mobileControls == null || this.mobileBattleModeActive)
         {
            return;
         }
         this.mobileBattleModeActive = true;
         Multitouch.mapTouchToMouse = false;
         Multitouch.inputMode = MultitouchInputMode.TOUCH_POINT;
         this.mobileControls.visible = true;
         this.refreshMobileControlMode();
         stage.addEventListener(TouchEvent.TOUCH_BEGIN,this.mobileTouchBegin,true);
         stage.addEventListener(TouchEvent.TOUCH_MOVE,this.mobileTouchMove);
         stage.addEventListener(TouchEvent.TOUCH_END,this.mobileTouchEnd);
         stage.addEventListener(Event.DEACTIVATE,this.mobileDeactivate);
         stage.addEventListener(Event.ENTER_FRAME,this.mobileControlFrame);
      }

      public function leaveMobileBattleMode() : void
      {
         if(this.mobileControls == null)
         {
            Multitouch.inputMode = MultitouchInputMode.NONE;
            Multitouch.mapTouchToMouse = true;
            return;
         }
         if(!this.mobileBattleModeActive)
         {
            Multitouch.inputMode = MultitouchInputMode.NONE;
            Multitouch.mapTouchToMouse = true;
            return;
         }
         this.mobileBattleModeActive = false;
         this.mobileControls.visible = false;
         Multitouch.inputMode = MultitouchInputMode.NONE;
         Multitouch.mapTouchToMouse = true;
         if(stage != null)
         {
            try
            {
               stage.removeEventListener(TouchEvent.TOUCH_BEGIN,this.mobileTouchBegin,true);
               stage.removeEventListener(TouchEvent.TOUCH_MOVE,this.mobileTouchMove);
               stage.removeEventListener(TouchEvent.TOUCH_END,this.mobileTouchEnd);
               stage.removeEventListener(Event.DEACTIVATE,this.mobileDeactivate);
               stage.removeEventListener(Event.ENTER_FRAME,this.mobileControlFrame);
            }
            catch(removeError:Error)
            {
            }
         }
         try
         {
            this.releaseMobileControls();
         }
         catch(error:Error)
         {
         }
      }

      private function mobileTouchBegin(e:TouchEvent) : void
      {
         var point0:Point = new Point(e.stageX,e.stageY);
         var screenLocal:Point = this.mobileControls.globalToLocal(point0);
         var local:Point = null;
         var baseLocal:Point = null;
         var attackMode:String = this.getMobileAttackMode();
         var attackLocal:Point = this.attackButton.globalToLocal(point0);
         if(this.attackButton.visible && attackLocal.length <= 38 && this.attackTouchId < 0)
         {
            this.attackTouchId = e.touchPointID;
            this.startMobileAttack();
            return;
         }
         if(this.beginMobileBattleBarControl(e,point0))
         {
            return;
         }
         baseLocal = screenLocal.x < Game.stageWidth * 0.5 ? this.moveBase.globalToLocal(point0) : this.aimBase.globalToLocal(point0);
         if(baseLocal.length > this.JOYSTICK_RADIUS && this.beginMobileUIControl(e,point0))
         {
            return;
         }
         if(screenLocal.x < Game.stageWidth * 0.5 && this.moveTouchId < 0)
         {
            baseLocal = this.moveBase.globalToLocal(point0);
            if(this.getMobileMoveMode() == "fixedStick" && baseLocal.length > this.JOYSTICK_RADIUS)
            {
               return;
            }
            local = this.moveKnob.globalToLocal(point0);
            this.moveTouchId = e.touchPointID;
            this.moveDragStart = this.moveBase.globalToLocal(point0);
            this.moveKnobStart.x = this.moveKnob.x;
            this.moveKnobStart.y = this.moveKnob.y;
            this.moveRelativeDrag = local.length <= 28;
            if(!this.moveRelativeDrag)
            {
               this.updateMoveJoystick(e.stageX,e.stageY);
            }
            return;
         }
         if(screenLocal.x >= Game.stageWidth * 0.5 && this.aimTouchId < 0)
         {
            baseLocal = this.aimBase.globalToLocal(point0);
            local = this.aimKnob.globalToLocal(point0);
            this.aimTouchId = e.touchPointID;
            this.aimDragStart = this.aimBase.globalToLocal(point0);
            this.aimKnobStart.x = this.aimKnob.x;
            this.aimKnobStart.y = this.aimKnob.y;
            this.aimRelativeDrag = (attackMode == "stickFire" || attackMode == "stickButton") && local.length <= 28;
            if(!this.aimRelativeDrag)
            {
               this.updateAimJoystick(e.stageX,e.stageY);
            }
            if(attackMode == "touchFire")
            {
               this.startMobileAttack();
            }
         }
      }

      private function beginMobileUIControl(e:TouchEvent, point0:Point) : Boolean
      {
         if(Game.uiGroup != null && Game.uiGroup.leftUI != null && Game.uiGroup.leftUI.mobileVolumeClick(point0.x,point0.y))
         {
            return true;
         }
         if(Game.uiGroup != null && Game.uiGroup.allback != null && Game.uiGroup.allback.mobileVolumeClick(point0.x,point0.y))
         {
            return true;
         }
         var target0:DisplayObject = this.getMobileClickTarget(point0);
         if(target0 != null)
         {
            this.mobileUITouches[e.touchPointID] = target0;
            return true;
         }
         return this.isMobileUIHit(point0);
      }

      private function beginMobileBattleBarControl(e:TouchEvent, point0:Point) : Boolean
      {
         var localPoint0:Point = this.globalToLocal(point0);
         if(localPoint0.y < 460)
         {
            return false;
         }
         var n:int = 0;
         var icon0:DisplayObject = null;
         var anchor0:Point = null;
         var previousAnchor0:Point = null;
         var nextAnchor0:Point = null;
         var slotLeft0:Number = 0;
         var slotRight0:Number = 0;
         var skillDefine:* = null;
         var skillBounds0:Rectangle = null;
         var code:int = 0;
         for(n = 0; n < this.arms_icon.length; n++)
         {
            icon0 = this.arms_icon[n];
            anchor0 = icon0.localToGlobal(new Point(0,0));
            previousAnchor0 = n > 0 ? DisplayObject(this.arms_icon[n - 1]).localToGlobal(new Point(0,0)) : null;
            nextAnchor0 = n + 1 < this.arms_icon.length ? DisplayObject(this.arms_icon[n + 1]).localToGlobal(new Point(0,0)) : null;
            slotLeft0 = previousAnchor0 != null ? (previousAnchor0.x + anchor0.x) * 0.5 : anchor0.x - (nextAnchor0.x - anchor0.x) * 0.5;
            slotRight0 = nextAnchor0 != null ? (anchor0.x + nextAnchor0.x) * 0.5 : anchor0.x + (anchor0.x - previousAnchor0.x) * 0.5;
            if(icon0.visible && this.arms_icon[n].itemsID != "" && point0.x >= slotLeft0 && point0.x < slotRight0)
            {
               Game.eventGroup.changArms(n);
               return true;
            }
         }
         for(n = 0; n < this.skillBox.arr.length; n++)
         {
            icon0 = this.skillBox.arr[n];
            skillDefine = Game.defineGroup.skill.arr[n];
            skillBounds0 = SkillIcon(icon0).boader.getBounds(stage);
            skillBounds0.inflate(6,6);
            if(icon0.visible && Game.gameData.playerData.getSkillLevel(skillDefine.name) > 0 && skillBounds0.contains(point0.x,point0.y))
            {
               code = Game.keysGroup.getBinding(skillDefine.name == "jump" ? "jumpSkill" : skillDefine.name);
               Game.keysGroup.setVirtualKey(code,true);
               this.mobileSkillTouches[e.touchPointID] = code;
               return true;
            }
         }
         return false;
      }

      private function getMobileClickTarget(point0:Point) : DisplayObject
      {
         var objects:Array = stage.getObjectsUnderPoint(point0);
         var object0:DisplayObject = null;
         var parent0:DisplayObject = null;
         var n:int = objects.length - 1;
         while(n >= 0)
         {
            object0 = objects[n] as DisplayObject;
            parent0 = object0;
            while(parent0 != null && parent0 != stage)
            {
               if(parent0 == this.mobileControls || parent0 == Game.gameSprite.shootMouseL)
               {
                  break;
               }
               if(parent0.visible && parent0["mouseEnabled"] && parent0.hasEventListener(MouseEvent.CLICK) && parent0 != this && parent0 != Game.gameSprite.topUIL && parent0 != Game.gameSprite.gamingUIL)
               {
                  return parent0;
               }
               parent0 = parent0.parent;
            }
            n--;
         }
         return null;
      }

      private function isMobileUIHit(point0:Point) : Boolean
      {
         var screenLocal:Point = this.mobileControls.globalToLocal(point0);
         if(screenLocal.y >= 460)
         {
            return true;
         }
         var objects:Array = stage.getObjectsUnderPoint(point0);
         var object0:DisplayObject = null;
         var parent0:DisplayObject = null;
         for each(object0 in objects)
         {
            parent0 = object0;
            while(parent0 != null)
            {
               if(parent0 == this.mobileControls)
               {
                  break;
               }
               if(parent0 == Game.gameSprite.topUIL || parent0 == Game.gameSprite.topTipL || parent0 == Game.gameSprite.goHomeL)
               {
                  return true;
               }
               parent0 = parent0.parent;
            }
         }
         return false;
      }

      private function moveTouchBegin(e:TouchEvent) : void
      {
         if(this.moveTouchId < 0)
         {
            this.moveTouchId = e.touchPointID;
            this.moveDragStart = this.moveBase.globalToLocal(new Point(e.stageX,e.stageY));
            this.moveKnobStart.x = this.moveKnob.x;
            this.moveKnobStart.y = this.moveKnob.y;
            this.moveRelativeDrag = this.moveDragStart.length <= 30;
            if(!this.moveRelativeDrag)
            {
               this.updateMoveJoystick(e.stageX,e.stageY);
            }
         }
      }

      private function aimTouchBegin(e:TouchEvent) : void
      {
         if(this.aimTouchId < 0)
         {
            this.aimTouchId = e.touchPointID;
            this.aimDragStart = this.aimBase.globalToLocal(new Point(e.stageX,e.stageY));
            this.aimKnobStart.x = this.aimKnob.x;
            this.aimKnobStart.y = this.aimKnob.y;
            this.aimRelativeDrag = this.aimDragStart.length <= 30;
            if(!this.aimRelativeDrag)
            {
               this.updateAimJoystick(e.stageX,e.stageY);
            }
         }
      }

      private function mobileTouchMove(e:TouchEvent) : void
      {
         if(e.touchPointID == this.moveTouchId)
         {
            this.updateMoveJoystick(e.stageX,e.stageY,this.moveRelativeDrag);
         }
         else if(e.touchPointID == this.aimTouchId)
         {
            this.updateAimJoystick(e.stageX,e.stageY,this.aimRelativeDrag);
         }
      }

      private function mobileTouchEnd(e:TouchEvent) : void
      {
         var skillCode:* = this.mobileSkillTouches[e.touchPointID];
         if(skillCode !== undefined)
         {
            Game.keysGroup.setVirtualKey(int(skillCode),false);
            delete this.mobileSkillTouches[e.touchPointID];
         }
         var clickTarget:DisplayObject = this.mobileUITouches[e.touchPointID] as DisplayObject;
         if(clickTarget != null)
         {
            delete this.mobileUITouches[e.touchPointID];
            if(clickTarget.stage != null && clickTarget.visible)
            {
               clickTarget.dispatchEvent(new MouseEvent(MouseEvent.CLICK,true,false,e.stageX,e.stageY));
            }
         }
         if(e.touchPointID == this.moveTouchId)
         {
            this.moveTouchId = -1;
            this.moveKnob.x = 0;
            this.moveKnob.y = 0;
            this.mobileMoveSector = "center";
            this.releaseMobileVerticalControl();
            Game.keysGroup.releaseVirtualMovement();
         }
         if(e.touchPointID == this.aimTouchId)
         {
            this.aimTouchId = -1;
            this.aimKnob.x = 0;
            this.aimKnob.y = 0;
            this.stopMobileAttack();
         }
         if(e.touchPointID == this.attackTouchId)
         {
            this.attackTouchId = -1;
            this.stopMobileAttack();
         }
      }

      private function updateMoveJoystick(stageX0:Number, stageY0:Number, relative:Boolean = false) : void
      {
         var local:Point = this.moveBase.globalToLocal(new Point(stageX0,stageY0));
         if(relative)
         {
            local.x = this.moveKnobStart.x + local.x - this.moveDragStart.x;
            local.y = this.moveKnobStart.y + local.y - this.moveDragStart.y;
         }
         var distance:Number = Math.sqrt(local.x * local.x + local.y * local.y);
         var scale:Number = distance > this.JOYSTICK_RADIUS ? this.JOYSTICK_RADIUS / distance : 1;
         this.moveKnob.x = local.x * scale;
         this.moveKnob.y = local.y * scale;
         if(distance < 14)
         {
            this.mobileMoveSector = "center";
         }
         else if(local.y < -18)
         {
            if(Math.abs(local.x) <= -local.y * 0.45)
            {
               this.mobileMoveSector = "up";
            }
            else
            {
               this.mobileMoveSector = local.x < 0 ? "upLeft" : "upRight";
            }
         }
         else if(local.x < -14)
         {
            this.mobileMoveSector = "left";
         }
         else if(local.x > 14)
         {
            this.mobileMoveSector = "right";
         }
         else
         {
            this.mobileMoveSector = "center";
         }
         Game.keysGroup.setVirtualKey(Game.keysGroup.getBinding("moveLeft"),this.mobileMoveSector == "left" || this.mobileMoveSector == "upLeft");
         Game.keysGroup.setVirtualKey(Game.keysGroup.getBinding("moveRight"),this.mobileMoveSector == "right" || this.mobileMoveSector == "upRight");
      }

      private function mobileControlFrame(e:Event) : void
      {
         var hero:* = null;
         var jumpSkill:* = null;
         var upperSector:Boolean = this.mobileMoveSector == "up" || this.mobileMoveSector == "upLeft" || this.mobileMoveSector == "upRight";
         if(!upperSector || this.moveTouchId < 0)
         {
            this.releaseMobileVerticalControl();
            return;
         }
         hero = Game.BG.hero;
         if(hero == null || !hero.getCtrlB())
         {
            this.releaseMobileVerticalControl();
            return;
         }
         jumpSkill = hero.skill.getSkill("jump");
         if(this.mobileGravityHeld)
         {
            if(jumpSkill == null || !jumpSkill.timeUseB)
            {
               this.mobileGravityHeld = false;
            }
            return;
         }
         if(jumpSkill != null && jumpSkill.timeUseB)
         {
            this.mobileGravityHeld = true;
            return;
         }
         if(this.mobileJumpDelayFrames > 0)
         {
            this.mobileJumpDelayFrames--;
            return;
         }
         if(hero.mot.getFloorB())
         {
            this.mobileGravityInterval = 0;
            if(this.mobileJumpCount == 0)
            {
               hero.key.toJump();
               this.mobileJumpDelayFrames = 8;
               this.mobileJumpCount = 1;
            }
            return;
         }
         if(this.mobileGravityInterval > 0)
         {
            --this.mobileGravityInterval;
            return;
         }
         if(hero.consumeAirGravity != null && hero.consumeAirGravity())
         {
            hero.mot.toAirGravity();
            this.mobileGravityInterval = 12;
            return;
         }
      }

      private function startMobileGravity(jumpSkill:*) : void
      {
         var hero:* = Game.BG == null ? null : Game.BG.hero;
         if(hero != null && hero.key.skillEnabled && Game.gameData.playerData.getSkillLevel("jump") > 0 && jumpSkill != null && jumpSkill.getUseB() && jumpSkill.useSkill())
         {
            this.mobileGravityHeld = true;
         }
      }

      private function releaseMobileVerticalControl() : void
      {
         var hero:* = Game.BG == null ? null : Game.BG.hero;
         var jumpSkill:* = hero == null ? null : hero.skill.getSkill("jump");
         if(this.mobileGravityHeld && jumpSkill != null && jumpSkill.timeUseB)
         {
            jumpSkill.closeSkill();
         }
         this.mobileJumpDelayFrames = 0;
         this.mobileJumpCount = 0;
         this.mobileGravityInterval = 0;
         this.mobileGravityHeld = false;
      }

      private function updateAimJoystick(stageX0:Number, stageY0:Number, relative:Boolean = false) : void
      {
         var attackMode:String = this.getMobileAttackMode();
         var local:Point = this.aimBase.globalToLocal(new Point(stageX0,stageY0));
         if(relative)
         {
            local.x = this.aimKnobStart.x + local.x - this.aimDragStart.x;
            local.y = this.aimKnobStart.y + local.y - this.aimDragStart.y;
         }
         var distance:Number = Math.sqrt(local.x * local.x + local.y * local.y);
         if(distance < 6)
         {
            return;
         }
         var scale:Number = distance > this.JOYSTICK_RADIUS ? this.JOYSTICK_RADIUS / distance : 1;
         this.aimKnob.x = local.x * scale;
         this.aimKnob.y = local.y * scale;
         this.mobileAimX = local.x / distance;
         this.mobileAimY = local.y / distance;
         this.mobileAimActive = true;
         var hero:* = Game.BG.hero;
         if(hero != null)
         {
            this.applyMobileAim(hero);
            if(attackMode == "stickFire" && distance >= this.ATTACK_RADIUS)
            {
               this.startMobileAttack();
            }
            else if(attackMode == "stickFire")
            {
               this.stopMobileAttack();
            }
         }
      }

      public function applyMobileAim(hero:*) : Boolean
      {
         if(!this.mobileAimActive || hero == null)
         {
            if(hero != null)
            {
               hero.mobileAimB = false;
            }
            return false;
         }
         hero.mobileAimB = true;
         hero.inMouseXY(hero.img.x + this.mobileAimX * 500,hero.img.y + this.mobileAimY * 500);
         return true;
      }

      private function mobileDeactivate(e:Event) : void
      {
         this.releaseMobileControls();
      }

      private function stopMobileAttack() : void
      {
         var hero:* = Game.BG == null ? null : Game.BG.hero;
         if(hero != null && this.mobileAttacking)
         {
            hero.attack.stopLoop();
            hero.SG.stopAll();
         }
         this.mobileAttacking = false;
      }

      private function startMobileAttack() : void
      {
         var hero:* = Game.BG == null ? null : Game.BG.hero;
         if(hero != null && !this.mobileAttacking && hero.noAttack_t == -1 && hero.getCtrlB())
         {
            hero.attackAll();
            this.mobileAttacking = true;
         }
      }

      private function releaseMobileControls() : void
      {
         var hero:* = Game.BG == null ? null : Game.BG.hero;
         if(hero != null)
         {
            hero.mobileAimB = false;
         }
         this.moveTouchId = -1;
         this.aimTouchId = -1;
         this.attackTouchId = -1;
         this.mobileMoveSector = "center";
         this.releaseMobileVerticalControl();
         for each(var skillCode:* in this.mobileSkillTouches)
         {
            Game.keysGroup.setVirtualKey(int(skillCode),false);
         }
         this.mobileSkillTouches = {};
         this.mobileUITouches = {};
         this.mobileAimActive = false;
         if(this.moveKnob != null)
         {
            this.moveKnob.x = 0;
            this.moveKnob.y = 0;
            this.aimKnob.x = 0;
            this.aimKnob.y = 0;
         }
         Game.keysGroup.releaseVirtualMovement();
         this.stopMobileAttack();
      }

      public function fleshKeyLabels() : *
      {
         var n:int = 0;
         var skillDefine:* = null;
         var skillIcon:* = null;
         if(this.arms_icon != null)
         {
            for(n = 0; n < this.arms_icon.length; n++)
            {
               this.arms_icon[n].numTxt.text = this.keyName(Game.keysGroup.weaponKeys[n]);
            }
         }
         if(this.skillBox != null)
         {
            for(n = 0; n < Game.defineGroup.skill.arr.length; n++)
            {
               skillDefine = Game.defineGroup.skill.arr[n];
               skillIcon = this.skillBox.arr[n];
               if(skillIcon != null && Game.keysGroup.skillKeys[skillDefine.name] !== undefined)
               {
                  skillIcon.keyTxt.text = this.keyName(int(Game.keysGroup.skillKeys[skillDefine.name]));
               }
            }
         }
      }

      private function keyName(code:int) : String
      {
         if(code == 32) return "空格";
         if(code >= 48 && code <= 90) return String.fromCharCode(code);
         return String(code);
      }
      
      public function showState(str0:String = "") : *
      {
         if(str0 == "")
         {
            this._mc.visible = true;
            this._mc2.visible = false;
         }
         else if(str0 == "arena")
         {
            this._mc.visible = false;
            this._mc2.visible = true;
         }
      }
      
      public function fleshNameAndHead() : *
      {
         this.playerName_txt.htmlText = "<font color=\'#FFFF00\'>" + this.GD.playerRank + "</font>  " + this.GD.playerName;
         this.head_btn.setText(this.GD.headLabel);
      }
      
      public function addTestText(str0:String) : *
      {
         var text2:String = null;
         var n:* = undefined;
         if(Game.gameDefine.getTestB())
         {
            this.testArr.unshift(str0);
            this.testArr.length = 20;
            text2 = "";
            for(n in this.testArr)
            {
               text2 = this.testArr[n] + "\n" + text2;
            }
            this.testTxt.text = text2;
         }
      }
      
      public function showTaskBox(str0:String = "") : *
      {
         this.task_mc.visible = true;
         if(str0 != "")
         {
            this.task_mc.txt.htmlText = str0;
         }
      }
      
      public function hideTaskBox() : *
      {
         this.task_mc.visible = false;
      }
      
      public function fleshTaskBox() : *
      {
         var td0:OneTaskDefine = Game.gameData.taskData.nowTask;
         var cd0:ChallengeTaskDefine = Game.gameData.challengeTaskData.nowTask;
         var cd2:CollectTaskDefine = Game.gameData.collectTaskData.nowTask;
         var cd3:CollectTaskDefine = Game.gameData.weekTaskData.nowTask;
         var str0:String = "";
         if(td0.state != "no")
         {
            str0 += td0.getDiffString() + "“" + this.getFontColor(td0.getLevelString(),"#33FF00") + "”";
            str0 += "\n击杀任意怪物";
            str0 += "\n已经击杀 " + this.getFontColor(td0.completeNum + "/" + td0.maxNum,"#33FF00") + " 只";
            if(td0.state == "complete")
            {
               str0 += this.getFontColor("（已完成）","#FFFF00");
            }
            this.showTaskBox(str0);
         }
         else if(cd0 is ChallengeTaskDefine)
         {
            str0 += cd0.getDiffString() + "“" + this.getFontColor(Game.LG.filter.getBeforeLevel(cd0.targetDiff,cd0.targetLevel).name,"#33FF00") + "”";
            str0 += "\n击杀目标“" + this.getFontColor(cd0.enemyName,"#33FF00") + "”";
            str0 += "\n" + this.getFontColor(cd0.getRequest(),"#FF66FF");
            if(cd0.state == "ing")
            {
               if(this.GD.challengeTaskData.getFail(cd0.index) == "timeout")
               {
                  str0 += this.getFontColor("（时间超出，未完成）","#FF0000");
               }
               else if(this.GD.challengeTaskData.getFail(cd0.index) == "died")
               {
                  str0 += this.getFontColor("（死亡一次，未完成）","#FF0000");
               }
               else
               {
                  str0 += this.getFontColor("（进行中……）","#33FF00");
               }
            }
            else if(cd0.state == "complete")
            {
               str0 += this.getFontColor("（已完成）","#FFFF00");
            }
            this.showTaskBox(str0);
         }
         else if(cd2 is CollectTaskDefine)
         {
            str0 += "“第六章-第九章”任意关卡";
            str0 += "\n收集“" + this.getFontColor(cd2.cnItems,"#FF66FF") + "”" + cd2.targetNum + "个\n";
            if(cd2.state == "ing")
            {
               str0 += this.getFontColor("（已收集" + this.GD.collectTaskData.nowNum + "个）","#33FF00");
            }
            else if(cd2.state == "complete")
            {
               str0 += this.getFontColor("（已完成）","#FFFF00");
            }
            this.showTaskBox(str0);
         }
         else if(cd3 is CollectTaskDefine)
         {
            str0 += "任意关卡";
            str0 += "\n杀死怪物" + cd3.targetNum + "个\n";
            if(cd3.state == "ing")
            {
               str0 += this.getFontColor("（已杀死" + this.GD.weekTaskData.nowNum + "个）","#33FF00");
            }
            else if(cd3.state == "complete")
            {
               str0 += this.getFontColor("（已完成）","#FFFF00");
            }
            this.showTaskBox(str0);
         }
         else
         {
            this.hideTaskBox();
         }
      }
      
      public function fleshBar() : *
      {
         var n:* = undefined;
         var id0:ArmsItemsData = null;
         var site0:int = 0;
         var icon0:GamingArmsIcon = null;
         this.GD.gameTime += 1 / 6;
         if(this.GD.gameTime >= (this.nowSaveNum + 1) * 10 * 60)
         {
            Game.eventGroup.weekExtraSave();
            Game.uiGroup.saveDataNoUI();
            ++this.nowSaveNum;
         }
         this.life_bar.inData(this.GD.nowLife,this.GD.maxLife);
         this.exp_bar.inData(this.GD.nowExp,this.GD.maxExp);
         this.gcoin_txt.text = String(this.GD.GCoin);
         this.score_txt.text = String(this.GD.score);
         this.time_txt.text = StringToDefine.getTimeStr(this.GD.gameTime);
         this.hitRate_txt.text = int(this.GD.hitBulletNum / this.GD.bulletNum * 1000) / 10 + " %";
         this.hurtNum_txt.text = int(this.GD.nowHurtNum) + "";
         var armsItems:ArmsItemsDataGroup = this.GD.armsItems;
         var arr0:Array = armsItems.equArr;
         for(n in arr0)
         {
            id0 = arr0[n];
            site0 = id0.site;
            icon0 = this.arms_icon[site0];
            icon0.setEnergy(id0.getEnergyPer());
         }
         if(Boolean(this.GD.nowArmsData))
         {
            this.energy_bar.inData(this.GD.nowArmsData.nowEnergy,this.GD.nowArmsData.maxEnergy);
         }
         else
         {
            this.energy_bar.inData(0,0);
         }
         if(this._bossBarTarget != null)
         {
            this.boss_bar.inData(this._bossBarTarget.define.nowLife,this._bossBarTarget.define.maxLife);
         }
         var bb0:Boolean = this.GD.challengeTaskData.timeTrigger(this.GD.gameTime);
         if(!bb0)
         {
            this.fleshTaskBox();
         }
         this._mc2.fleshBar();
      }
      
      private function getFontColor(str:String, _color1:String = "#999999") : String
      {
         return "<font color=\'" + _color1 + "\'>" + str + "</font>";
      }
      
      public function fleshArms() : *
      {
         var n:* = undefined;
         var icon0:GamingArmsIcon = null;
         var armsItems:ArmsItemsDataGroup = this.GD.armsItems;
         for(n in this.arms_icon)
         {
            icon0 = this.arms_icon[n];
            icon0.inData_byItems(armsItems.getEquipBySite(n));
            icon0.setState(armsItems.armsState[n]);
            icon0.showAlpha();
         }
         this.arms_icon[this.GD.nowArmsIndex].show();
         this.fleshTaskBox();
         this.timeLimit_txt.visible = false;
      }
      
      public function fleshShowArms() : *
      {
      }
      
      public function hideSkillIcon() : *
      {
         this.skillBox.y = 580;
      }
      
      public function showSkillIcon() : *
      {
         TweenLite.to(this.skillBox,0.5,{
            "y":486,
            "ease":Back.easeOut
         });
      }
      
      public function showArmsBar() : *
      {
         var n:* = undefined;
         var icon0:* = undefined;
         for(n in this.arms_icon)
         {
            icon0 = this.arms_icon[n];
            TweenLite.to(icon0,0.5,{
               "y":this.arms_y,
               "ease":Back.easeOut
            });
         }
      }
      
      public function hideArmsBar() : *
      {
         var n:* = undefined;
         var icon0:* = undefined;
         for(n in this.arms_icon)
         {
            icon0 = this.arms_icon[n];
            icon0.y = 580;
         }
      }
      
      public function showBossBar() : *
      {
         if(!this.bossBarB)
         {
            this.bossBarB = true;
            this.boss_bar.visible = true;
            this.boss_bar.y = -53.5;
            TweenLite.to(this.boss_bar,0.3,{
               "y":23.5,
               "ease":Back.easeOut
            });
         }
      }
      
      public function hideBossBar() : *
      {
         if(this.bossBarB)
         {
            this.bossBarB = false;
            TweenLite.to(this.boss_bar,0.3,{
               "y":-53.5,
               "ease":Back.easeIn
            });
         }
      }
      
      public function set bossBarTarget(b0:*) : *
      {
         var type0:int = 0;
         if(this._bossBarTarget != b0)
         {
            this._bossBarTarget = b0;
            if(this._bossBarTarget != null)
            {
               this.showBossBar();
               this.boss_bar.inData(this._bossBarTarget.define.nowLife,this._bossBarTarget.define.maxLife);
               type0 = 0;
               if(this._bossBarTarget.type == "super")
               {
                  type0 = 1;
               }
               else if(this._bossBarTarget.type == "champion")
               {
                  type0 = 2;
               }
               else if(this._bossBarTarget.type == "boss")
               {
                  type0 = 0;
               }
               this.boss_bar.unitName(this._bossBarTarget.define.name,type0,this._bossBarTarget.ai.skill.getCn());
            }
            else
            {
               this.hideBossBar();
            }
         }
      }
      
      public function get bossBarTarget() : *
      {
         return this._bossBarTarget;
      }
   }
}

