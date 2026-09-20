package UI.server
{
   import UI.button.SountoScrollBar;
   import data.StringDate;
   import com.adobe.serialization.json.JSON2;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.display.Loader;
   import flash.display.SimpleButton;
   import flash.display.Sprite;
   import flash.utils.ByteArray;
   import flash.events.Event;
   import flash.events.IOErrorEvent;
   import flash.events.MouseEvent;
   import flash.net.URLLoader;
   import flash.net.URLLoaderDataFormat;
   import flash.net.URLRequest;
   import flash.net.SharedObject;
   import flash.net.navigateToURL;
   import flash.text.StyleSheet;
   import flash.text.TextField;
   import flash.text.TextFieldType;
   import flash.text.TextFormat;
   import flash.utils.getDefinitionByName;
   
   public class ServerUI extends MovieClip
   {
      
      public var logo:MovieClip;
      
      private var _isnew:Boolean;
      
      public var btn_1:MovieClip;
      
      public var btn_2:MovieClip;
      
      public var btn_3:MovieClip;
      
      public var btn_4:MovieClip;
      
      public var btn_5:MovieClip;
      
      public var btn_6:MovieClip;
      
      public var btn_7:MovieClip;
      
      public var btn_8:MovieClip;
      
      public var name_1:MovieClip;
      
      public var name_2:MovieClip;
      
      public var name_3:MovieClip;
      
      public var name_4:MovieClip;
      
      public var name_5:MovieClip;
      
      public var name_6:MovieClip;
      
      public var name_7:MovieClip;
      
      public var name_8:MovieClip;
      
      public var btn_back:SimpleButton;
      
      public var btn_new:SimpleButton;
      
      public var btn_continue:SimpleButton;
      
      public var btn_introd:SimpleButton;
      
      public var btn_bbs:SimpleButton;
      
      public var btn_maker:SimpleButton;
      
      public var producer_mc:MovieClip;
      
      public var intro_mc:MovieClip;
      
      public var versionNumber_txt:TextField;
      
      public var cover_mc:Sprite;
      
      public var context_mc:Sprite = new Sprite();
      
      public var sBar:SountoScrollBar = new SountoScrollBar();
      
      public var bbs_btn:SimpleButton;
      
      public var btn_arr:Array = [];
      
      private var fun:Function;
      
      private var fun2:Function;
      
      public var txt1:TextField;
      
      public var str1:TextField;
      
      private var _selectIdex:int = 7;
      
      private var _selectSaveData:StringDate = null;
      
      private var notice_txt:TextField;
      
      private var noticeLoader:URLLoader;

      private var gameNoticeLoader:URLLoader;

      private var saveDataPanel:Sprite;

      private var saveDataStatus:TextField;

      private var backupPathText:TextField;

      private var exportPathText:TextField;

      private var saveDataEntryFace:Sprite;

      private var saveDirectoryBrowser:*;

      private var saveDirectoryRole:String = "";

      private var backupDirectoryPath:String = "";

      private var exportDirectoryPath:String = "";

      private var modifierPanel:Sprite;

      private var modifierStatus:TextField;

      private var modifierSlotButtons:Array = [];

      private var modifierToggles:Object = {};

      private var modifierToggleStates:Object = {};

      private var modifierSelectedSlot:int = -1;

      private var modifierSlots:Array;

      private var modifierSlotContent:Sprite;

      private var modifierSlotMask:Sprite;

      private var modifierSlotThumb:Sprite;

      private var modifierSlotThumbStartY:Number = 0;

      private var modifierSlotDragStartY:Number = 0;

      private var modifierFeatureContent:Sprite;

      private var modifierFeatureMask:Sprite;

      private var modifierFeatureThumb:Sprite;

      private var modifierFeatureThumbStartY:Number = 0;

      private var modifierFeatureDragStartY:Number = 0;

      private var modifierLevelInput:TextField;

      private var sasaveBridgeReady:Boolean = true;

      private var sasaveContextError:String = "";

      private var sasavePanel:Sprite;

      private var sasaveStatus:TextField;

      private var sasaveSlotButtons:Array = [];

      private var sasaveMode:String = "";

      private var sasaveTargetIndex:int = -1;

      private var sasavePendingSlot:Object;

      private var sasaveManifest:Object;

      private var sasaveRisk:int = 0;

      private var sasaveExportFileButton:Sprite;

      private var sasaveExportShareButton:Sprite;

      private var sasaveExportFilePath:String = "";

      private var sasaveExportManifestPath:String = "";

      private var sasaveExportName:String = "";

      private var sasaveImportFileButton:Sprite;

      private var sasaveImportReceiveButton:Sprite;

      private var sasaveConfirmButton:Sprite;

      public function ServerUI()
      {
         super();
         this.InitSever();
      }
      
      public function InitSever() : void
      {
         var mc0:Sprite = null;
         this.gotoAndStop(1);
         this.hideMainMenuNoticeBadge();
         var sheet:StyleSheet = new StyleSheet();
         sheet.parseCSS("a:link {text-decoration:none;}a:hover {text-decoration:underline;color:#FFFF00;}a:active {text-decoration:none;}");
         this.txt1.styleSheet = sheet;
         this.txt1.htmlText = "本游戏开发，感谢@凉粉、@风水、@小熊、@愿原力与你同在、@光电游侠，以及所有在内测群提供帮助的玩家们。\n\n特别感谢@客观在2.5版本中的贡献。";
         this.loadGameNotice();
         this.versionNumber_txt.text = "超合金离线优化海豹版，1.2";
         this.producer_mc.visible = false;
         this.intro_mc.visible = false;
         this.btn_new.addEventListener(MouseEvent.CLICK,this.gotonew);
         this.btn_continue.addEventListener(MouseEvent.CLICK,this.gotocontinue);
         this.btn_introd.addEventListener(MouseEvent.CLICK,this.gotointro);
         this.btn_bbs.addEventListener(MouseEvent.CLICK,this.toggleSaveDataPanel);
         this.btn_bbs.addEventListener(MouseEvent.MOUSE_OVER,this.saveDataEntryOver);
         this.btn_bbs.addEventListener(MouseEvent.MOUSE_OUT,this.saveDataEntryOut);
         this.btn_bbs.addEventListener(MouseEvent.MOUSE_DOWN,this.saveDataEntryOver);
         this.btn_bbs.addEventListener(MouseEvent.MOUSE_UP,this.saveDataEntryOut);
         this.btn_maker.addEventListener(MouseEvent.CLICK,this.gotomake);
         (this.producer_mc["return_btn"] as SimpleButton).addEventListener(MouseEvent.CLICK,this.hideProducer);
         (this.intro_mc["return_btn"] as SimpleButton).addEventListener(MouseEvent.CLICK,this.hideIntro);
         addChild(this.context_mc);
         this.context_mc.x = this.cover_mc.x;
         this.context_mc.y = this.cover_mc.y;
         this.sBar.x = 554;
         this.sBar.y = 342;
         addChild(this.sBar);
         this.context_mc.mask = this.cover_mc;
         if(this.context_mc.numChildren == 0)
         {
            mc0 = this.createOfflineNotice();
            this.sBar.setHigh(this.cover_mc.height - 6);
            this.context_mc.addChild(mc0);
            this.sBar.setTarget(this.context_mc);
            this.context_mc.addEventListener(MouseEvent.MOUSE_WHEEL,this.scrollOfflineNotice);
            this.cover_mc.addEventListener(MouseEvent.MOUSE_WHEEL,this.scrollOfflineNotice);
            this.loadOfflineNotice();
         }
         addChild(this.producer_mc);
         addChild(this.intro_mc);
         this.createSaveDataPanel();
         this.createModifierPanel();
         this.createSasavePanel();
         this.initSasaveContext();
         this.createSaveDataEntryFace();
      }

      private function createSaveDataEntryFace() : void
      {
         var bounds0:* = this.btn_bbs.getBounds(this);
         this.saveDataEntryFace = new Sprite();
         this.saveDataEntryFace.mouseEnabled = false;
         this.saveDataEntryFace.mouseChildren = false;
         this.saveDataEntryFace.x = bounds0.x;
         this.saveDataEntryFace.y = bounds0.y;
         this.saveDataEntryFace.scaleX = bounds0.width / 188;
         this.saveDataEntryFace.scaleY = bounds0.height / 48;
         this.addSaveDataEntryImage("ui/save-data/save-data-up.png","normal",true);
         this.addSaveDataEntryImage("ui/save-data/save-data-over.png","over",false);
         addChild(this.saveDataEntryFace);
      }

      private function addSaveDataEntryImage(path0:String, role0:String, visible0:Boolean) : void
      {
         var loader0:Loader = new Loader();
         loader0.name = role0;
         loader0.visible = visible0;
         loader0.mouseEnabled = false;
         this.saveDataEntryFace.addChild(loader0);
         loader0.load(new URLRequest(path0));
      }

      private function saveDataEntryOver(e:MouseEvent) : void
      {
         this.setSaveDataEntryState(true);
      }

      private function saveDataEntryOut(e:MouseEvent) : void
      {
         this.setSaveDataEntryState(false);
      }

      private function setSaveDataEntryState(over0:Boolean) : void
      {
         var child0:DisplayObject = null;
         var i0:int = 0;
         while(i0 < this.saveDataEntryFace.numChildren)
         {
            child0 = this.saveDataEntryFace.getChildAt(i0);
            if(child0.name == "normal") child0.visible = !over0;
            if(child0.name == "over") child0.visible = over0;
            i0++;
         }
      }

      private function createSaveDataPanel() : void
      {
         var title0:TextField = null;
         var close0:Sprite = null;
         var import0:Sprite = null;
         var export0:Sprite = null;
         var backup0:Sprite = null;
         var modifier0:Sprite = null;
         var backupOpen0:Sprite = null;
         var backupSet0:Sprite = null;
         var exportOpen0:Sprite = null;
         var exportSet0:Sprite = null;
         if(this.saveDataPanel != null)
         {
            addChild(this.saveDataPanel);
            return;
         }
         this.saveDataPanel = new Sprite();
         this.saveDataPanel.graphics.beginFill(0,0.62);
         this.saveDataPanel.graphics.drawRect(0,0,960,560);
         this.saveDataPanel.graphics.endFill();
         this.saveDataPanel.graphics.beginFill(329225,0.98);
         this.saveDataPanel.graphics.lineStyle(3,65535,1);
         this.saveDataPanel.graphics.drawRect(130,60,700,445);
         this.saveDataPanel.graphics.endFill();
         title0 = this.createSaveDataText("存档数据",28,65535,true,700,42);
         title0.x = 130;
         title0.y = 82;
         this.saveDataPanel.addChild(title0);
         import0 = this.createSaveDataButton("导入存档","import",190,145,250,58);
         export0 = this.createSaveDataButton("导出存档","export",520,145,250,58);
         this.saveDataPanel.addChild(import0);
         this.saveDataPanel.addChild(export0);
         backup0 = this.createSaveDataButton("存档备份","backup",190,225,250,52);
         this.saveDataPanel.addChild(backup0);
         modifier0 = this.createSaveDataButton("存档修改器","modifier",520,225,250,52);
         this.saveDataPanel.addChild(modifier0);
         this.backupPathText = this.createSaveDataText("备份路径：尚未设置",15,10092543,false,390,32);
         this.backupPathText.x = 175;
         this.backupPathText.y = 305;
         this.backupPathText.defaultTextFormat.align = "left";
         this.saveDataPanel.addChild(this.backupPathText);
         backupOpen0 = this.createSaveDataButton("打开","backupOpen",575,300,82,36);
         backupSet0 = this.createSaveDataButton("设置","backupSet",675,300,82,36);
         this.saveDataPanel.addChild(backupOpen0);
         this.saveDataPanel.addChild(backupSet0);
         this.exportPathText = this.createSaveDataText("导出路径：尚未设置",15,10092543,false,390,32);
         this.exportPathText.x = 175;
         this.exportPathText.y = 360;
         this.exportPathText.defaultTextFormat.align = "left";
         this.saveDataPanel.addChild(this.exportPathText);
         exportOpen0 = this.createSaveDataButton("打开","exportOpen",575,355,82,36);
         exportSet0 = this.createSaveDataButton("设置","exportSet",675,355,82,36);
         this.saveDataPanel.addChild(exportOpen0);
         this.saveDataPanel.addChild(exportSet0);
         this.saveDataStatus = this.createSaveDataText("",13,10092543,false,500,48);
         this.saveDataStatus.x = 175;
         this.saveDataStatus.y = 405;
         this.saveDataStatus.defaultTextFormat.align = "left";
         this.saveDataStatus.multiline = true;
         this.saveDataStatus.wordWrap = true;
         this.saveDataStatus.selectable = true;
         this.saveDataStatus.mouseEnabled = true;
         this.saveDataPanel.addChild(this.saveDataStatus);
         close0 = this.createSaveDataButton("关闭","close",690,450,88,34);
         this.saveDataPanel.addChild(close0);
         this.loadSaveDirectorySettings();
         this.saveDataPanel.visible = false;
         addChild(this.saveDataPanel);
      }

      private function createSaveDataButton(text0:String, role0:String, x0:Number, y0:Number, width0:Number = 210, height0:Number = 68) : Sprite
      {
         var button0:Sprite = new Sprite();
         var label0:TextField = null;
         button0.name = role0;
         button0.buttonMode = true;
         button0.mouseChildren = false;
         button0.x = x0;
         button0.y = y0;
         button0.graphics.beginFill(263177,1);
         button0.graphics.lineStyle(3,65535,1);
         button0.graphics.drawRect(0,0,width0,height0);
         button0.graphics.endFill();
         label0 = this.createSaveDataText(text0,height0 > 40 ? 24 : 15,16777215,true,width0,height0);
         label0.y = height0 > 40 ? 17 : 7;
         button0.addChild(label0);
         button0.addEventListener(MouseEvent.CLICK,this.saveDataPanelClick);
         return button0;
      }

      private function createSaveDataText(text0:String, size0:int, color0:uint, bold0:Boolean, width0:Number, height0:Number) : TextField
      {
         var field0:TextField = new TextField();
         var format0:TextFormat = new TextFormat("_sans",size0,color0,bold0);
         format0.align = "center";
         field0.defaultTextFormat = format0;
         field0.text = text0;
         field0.width = width0;
         field0.height = height0;
         field0.selectable = false;
         field0.mouseEnabled = false;
         return field0;
      }

      private function toggleSaveDataPanel(e:MouseEvent = null) : void
      {
         this.saveDataPanel.visible = !this.saveDataPanel.visible;
         if(this.saveDataPanel.visible)
         {
            this.saveDataStatus.text = "";
            setChildIndex(this.saveDataPanel,numChildren - 1);
         }
      }

      private function saveDataPanelClick(e:MouseEvent) : void
      {
         var role0:String = e.currentTarget.name;
         if(role0 == "close")
         {
            this.saveDataPanel.visible = false;
            return;
         }
         if(role0 == "backup")
         {
            this.saveDataStatus.text = this.backupDirectoryPath == "" ? "请先设置备份路径。" : "备份路径已设置，备份写入功能待下一步接入。";
            return;
         }
         if(role0 == "modifier")
         {
            this.openModifierPanel();
            return;
         }
         if(role0 == "backupSet")
         {
            this.chooseSaveDirectory("backup");
            return;
         }
         if(role0 == "backupOpen")
         {
            this.openSavedDirectory(this.backupDirectoryPath,"请先设置备份路径。");
            return;
         }
         if(role0 == "exportSet")
         {
            this.chooseSaveDirectory("export");
            return;
         }
         if(role0 == "exportOpen")
         {
            this.openSavedDirectory(this.exportDirectoryPath,"请先设置导出路径。");
            return;
         }
         if(role0 == "import")
         {
            this.consumeSharedSasave(false);
            return;
         }
         this.openSasaveExport();
      }

      private function createModifierPanel() : void
      {
         var title0:TextField = null;
         var hint0:TextField = null;
         var keys0:Array = ["modInfiniteEnergy","modGod","modOneHit","modCraftFree","modFreeSkillUpgrade","modNoExtraCooldown","modNoTaskCooldown","modInstantTaskComplete","modNoSkillCooldown","modUnlockAll","modFreeTasksAndPurchases","modUnlimitedGifts"];
         var labels0:Array = ["无限能量","车身无敌","一击必杀","研发无视条件","技能升级无消耗","副本挑战无冷却","任务无冷却时间","任务立即完成","技能无冷却时间","关卡全开","购买无视条件且不消耗资源","礼包无限领取"];
         var i0:int = 0;
         if(this.modifierPanel != null)
         {
            return;
         }
         this.modifierPanel = new Sprite();
         this.modifierPanel.graphics.beginFill(0,0.82);
         this.modifierPanel.graphics.drawRect(0,0,960,560);
         this.modifierPanel.graphics.endFill();
         this.modifierPanel.graphics.beginFill(329225,1);
         this.modifierPanel.graphics.lineStyle(3,65535,1);
         this.modifierPanel.graphics.drawRect(90,35,780,490);
         this.modifierPanel.graphics.endFill();
         title0 = this.createSaveDataText("存档修改器",28,65535,true,780,40);
         title0.x = 90;
         title0.y = 54;
         this.modifierPanel.addChild(title0);
         hint0 = this.createSaveDataText("选择要修改的存档槽位",16,10092543,false,720,26);
         hint0.x = 120;
         hint0.y = 98;
         this.modifierPanel.addChild(hint0);
         this.modifierSlotContent = new Sprite();
         this.modifierSlotContent.x = 125;
         this.modifierSlotContent.y = 135;
         this.modifierPanel.addChild(this.modifierSlotContent);
         this.modifierSlotMask = new Sprite();
         this.modifierSlotMask.graphics.beginFill(16777215,1);
         this.modifierSlotMask.graphics.drawRect(125,135,710,86);
         this.modifierSlotMask.graphics.endFill();
         this.modifierPanel.addChild(this.modifierSlotMask);
         this.modifierSlotContent.mask = this.modifierSlotMask;
         this.modifierPanel.graphics.lineStyle(2,34952,1);
         this.modifierPanel.graphics.drawRect(830,135,24,86);
         this.modifierSlotThumb = new Sprite();
         this.modifierSlotThumb.buttonMode = true;
         this.modifierSlotThumb.graphics.beginFill(65535,1);
         this.modifierSlotThumb.graphics.drawRect(0,0,24,44);
         this.modifierSlotThumb.graphics.endFill();
         this.modifierSlotThumb.x = 830;
         this.modifierSlotThumb.y = 135;
         this.modifierSlotThumb.addEventListener(MouseEvent.MOUSE_DOWN,this.modifierSlotThumbDown);
         this.modifierPanel.addChild(this.modifierSlotThumb);
         this.modifierFeatureContent = new Sprite();
         this.modifierFeatureContent.x = 145;
         this.modifierFeatureContent.y = 245;
         this.modifierPanel.addChild(this.modifierFeatureContent);
         this.modifierFeatureMask = new Sprite();
         this.modifierFeatureMask.graphics.beginFill(16777215,1);
         this.modifierFeatureMask.graphics.drawRect(145,245,645,170);
         this.modifierFeatureMask.graphics.endFill();
         this.modifierPanel.addChild(this.modifierFeatureMask);
         this.modifierFeatureContent.mask = this.modifierFeatureMask;
         this.modifierPanel.graphics.lineStyle(2,34952,1);
         this.modifierPanel.graphics.drawRect(798,245,24,170);
         this.modifierFeatureThumb = new Sprite();
         this.modifierFeatureThumb.buttonMode = true;
         this.modifierFeatureThumb.graphics.beginFill(65535,1);
         this.modifierFeatureThumb.graphics.drawRect(0,0,24,72);
         this.modifierFeatureThumb.graphics.endFill();
         this.modifierFeatureThumb.x = 798;
         this.modifierFeatureThumb.y = 245;
         this.modifierFeatureThumb.addEventListener(MouseEvent.MOUSE_DOWN,this.modifierFeatureThumbDown);
         this.modifierPanel.addChild(this.modifierFeatureThumb);
         while(i0 < keys0.length)
         {
            this.modifierFeatureContent.addChild(this.createModifierToggle(labels0[i0],keys0[i0],i0 % 2 * 345,int(i0 / 2) * 58));
            i0++;
         }
         // Keep the level editor below the expanded modifier list so the new purchase/gift toggles
         // remain visible inside the scrollable feature area.
         this.modifierFeatureContent.addChild(this.createModifierLevelEditor(0,410));
         this.modifierStatus = this.createSaveDataText("",14,10092543,false,650,38);
         this.modifierStatus.x = 145;
         this.modifierStatus.y = 425;
         this.modifierStatus.multiline = true;
         this.modifierStatus.wordWrap = true;
         this.modifierPanel.addChild(this.modifierStatus);
         this.modifierPanel.addChild(this.createModifierCommand("保存修改","modifierSave",555,470,130,38));
         this.modifierPanel.addChild(this.createModifierCommand("关闭","modifierClose",705,470,110,38));
         this.modifierPanel.visible = false;
         addChild(this.modifierPanel);
      }

      private function createModifierCommand(text0:String, role0:String, x0:Number, y0:Number, width0:Number, height0:Number) : Sprite
      {
         var button0:Sprite = this.createSaveDataButton(text0,role0,x0,y0,width0,height0);
         button0.removeEventListener(MouseEvent.CLICK,this.saveDataPanelClick);
         button0.addEventListener(MouseEvent.CLICK,this.modifierClick);
         return button0;
      }

      private function createModifierToggle(label0:String, key0:String, x0:Number, y0:Number) : Sprite
      {
         var toggle0:Sprite = new Sprite();
         var labelField0:TextField = null;
         toggle0.name = key0;
         toggle0.buttonMode = true;
         toggle0.mouseChildren = false;
         toggle0.x = x0;
         toggle0.y = y0;
         toggle0.graphics.beginFill(263177,1);
         toggle0.graphics.lineStyle(2,65535,1);
         toggle0.graphics.drawRect(0,0,300,44);
         toggle0.graphics.endFill();
         labelField0 = this.createSaveDataText("□  " + label0,18,16777215,true,300,32);
         labelField0.name = "label";
         labelField0.y = 10;
         toggle0.addChild(labelField0);
         toggle0.addEventListener(MouseEvent.CLICK,this.modifierClick);
         this.modifierToggles[key0] = toggle0;
         return toggle0;
      }

      private function createModifierLevelEditor(x0:Number, y0:Number) : Sprite
      {
         var editor0:Sprite = new Sprite();
         var label0:TextField = null;
         editor0.x = x0;
         editor0.y = y0;
         editor0.graphics.beginFill(263177,1);
         editor0.graphics.lineStyle(2,65535,1);
         editor0.graphics.drawRect(0,0,645,46);
         editor0.graphics.endFill();
         label0 = this.createSaveDataText("自定义人物等级（游戏显示等级）",17,16777215,true,390,32);
         label0.x = 8;
         label0.y = 10;
         editor0.addChild(label0);
         this.modifierLevelInput = this.createSaveDataText("1",18,65535,true,190,32);
         this.modifierLevelInput.x = 430;
         this.modifierLevelInput.y = 7;
         this.modifierLevelInput.type = TextFieldType.INPUT;
         this.modifierLevelInput.restrict = "0-9";
         this.modifierLevelInput.maxChars = 3;
         this.modifierLevelInput.selectable = true;
         this.modifierLevelInput.mouseEnabled = true;
         this.modifierLevelInput.border = true;
         this.modifierLevelInput.borderColor = 65535;
         this.modifierLevelInput.background = true;
         this.modifierLevelInput.backgroundColor = 0;
         editor0.addChild(this.modifierLevelInput);
         return editor0;
      }

      private function openModifierPanel() : void
      {
         var so0:SharedObject = null;
         var root0:Object = null;
         try
         {
            so0 = SharedObject.getLocal("superalloy_mobile_save","/");
            root0 = so0.data.saveContainer;
            if(root0 == null || !(root0.localSlots is Array))
            {
               this.saveDataStatus.text = "没有找到可修改的手机版存档。";
               return;
            }
            this.modifierSlots = root0.localSlots as Array;
            this.refreshModifierSlots();
            this.modifierPanel.visible = true;
            setChildIndex(this.modifierPanel,numChildren - 1);
         }
         catch(error:Error)
         {
            this.saveDataStatus.text = "读取手机版存档失败：" + error.message;
         }
      }

      private function refreshModifierSlots() : void
      {
         var old0:Sprite = null;
         var slot0:Object = null;
         var data0:Object = null;
         var button0:Sprite = null;
         var visualNumbers0:Array = [2,3,1,4,5,6,7,8];
         var entries0:Array = [];
         var entry0:Object = null;
         var i0:int = 0;
         while(this.modifierSlotButtons.length > 0)
         {
            old0 = this.modifierSlotButtons.pop() as Sprite;
            if(old0 != null && old0.parent == this.modifierSlotContent)
            {
               this.modifierSlotContent.removeChild(old0);
            }
         }
         this.modifierSelectedSlot = -1;
         i0 = 0;
         while(i0 < this.modifierSlots.length && i0 < 8)
         {
            slot0 = this.modifierSlots[i0];
            if(slot0 != null && slot0.data != null)
            {
               entries0.push({"index":i0,"number":int(visualNumbers0[i0])});
            }
            i0++;
         }
         entries0.sortOn("number",Array.NUMERIC);
         i0 = 0;
         while(i0 < entries0.length)
         {
            entry0 = entries0[i0];
            data0 = this.modifierSlots[int(entry0.index)].data;
            button0 = this.createModifierCommand(String(entry0.number) + "号 " + String(data0.playerName || "未知角色") + " Lv." + String(int(data0.level || 0) + 1),"modifierSlot_" + String(entry0.index),i0 % 2 * 360,int(i0 / 2) * 48,350,38);
            this.modifierSlotButtons.push(button0);
            this.modifierSlotContent.addChild(button0);
            i0++;
         }
         this.modifierSlotContent.y = 135;
         this.modifierSlotThumb.y = 135;
         this.modifierSlotThumb.visible = entries0.length > 4;
         if(this.modifierSlotButtons.length == 0)
         {
            this.modifierStatus.text = "没有找到有效的存档槽位。";
            this.setModifierControlsEnabled(false);
         }
         else
         {
            this.selectModifierSlot(int(String(this.modifierSlotButtons[0].name).split("_")[1]));
         }
      }

      private function modifierSlotThumbDown(e:MouseEvent) : void
      {
         this.modifierSlotDragStartY = this.modifierPanel.mouseY;
         this.modifierSlotThumbStartY = this.modifierSlotThumb.y;
         stage.addEventListener(MouseEvent.MOUSE_MOVE,this.modifierSlotThumbMove);
         stage.addEventListener(MouseEvent.MOUSE_UP,this.modifierSlotThumbUp);
      }

      private function modifierSlotThumbMove(e:MouseEvent) : void
      {
         var thumbRange0:Number = 42;
         var contentHeight0:Number = Math.ceil(this.modifierSlotButtons.length / 2) * 48;
         var contentRange0:Number = Math.max(0,contentHeight0 - 86);
         var newY0:Number = this.modifierSlotThumbStartY + this.modifierPanel.mouseY - this.modifierSlotDragStartY;
         newY0 = Math.max(135,Math.min(135 + thumbRange0,newY0));
         this.modifierSlotThumb.y = newY0;
         this.modifierSlotContent.y = 135 - (newY0 - 135) / thumbRange0 * contentRange0;
         e.updateAfterEvent();
      }

      private function modifierSlotThumbUp(e:MouseEvent) : void
      {
         stage.removeEventListener(MouseEvent.MOUSE_MOVE,this.modifierSlotThumbMove);
         stage.removeEventListener(MouseEvent.MOUSE_UP,this.modifierSlotThumbUp);
      }

      private function modifierFeatureThumbDown(e:MouseEvent) : void
      {
         this.modifierFeatureDragStartY = this.modifierPanel.mouseY;
         this.modifierFeatureThumbStartY = this.modifierFeatureThumb.y;
         stage.addEventListener(MouseEvent.MOUSE_MOVE,this.modifierFeatureThumbMove);
         stage.addEventListener(MouseEvent.MOUSE_UP,this.modifierFeatureThumbUp);
      }

      private function modifierFeatureThumbMove(e:MouseEvent) : void
      {
         var thumbRange0:Number = 98;
         var contentRange0:Number = 280;
         var newY0:Number = this.modifierFeatureThumbStartY + this.modifierPanel.mouseY - this.modifierFeatureDragStartY;
         newY0 = Math.max(245,Math.min(245 + thumbRange0,newY0));
         this.modifierFeatureThumb.y = newY0;
         this.modifierFeatureContent.y = 245 - (newY0 - 245) / thumbRange0 * contentRange0;
         e.updateAfterEvent();
      }

      private function modifierFeatureThumbUp(e:MouseEvent) : void
      {
         stage.removeEventListener(MouseEvent.MOUSE_MOVE,this.modifierFeatureThumbMove);
         stage.removeEventListener(MouseEvent.MOUSE_UP,this.modifierFeatureThumbUp);
      }

      private function modifierClick(e:MouseEvent) : void
      {
         var role0:String = e.currentTarget.name;
         if(role0 == "modifierClose")
         {
            this.modifierPanel.visible = false;
            return;
         }
         if(role0 == "modifierSave")
         {
            this.saveModifierChanges();
            return;
         }
         if(role0.indexOf("modifierSlot_") == 0)
         {
            this.selectModifierSlot(int(role0.split("_")[1]));
            return;
         }
         if(this.modifierToggles.hasOwnProperty(role0))
         {
            this.modifierToggleStates[role0] = !Boolean(this.modifierToggleStates[role0]);
            this.drawModifierToggle(e.currentTarget as Sprite);
         }
      }

      private function selectModifierSlot(index0:int) : void
      {
         var slot0:Object = this.modifierSlots[index0];
         var data0:Object = null;
         var key0:String = null;
         var button0:Sprite = null;
         var i0:int = 0;
         if(slot0 == null || slot0.data == null)
         {
            return;
         }
         this.modifierSelectedSlot = index0;
         data0 = slot0.data;
         this.modifierLevelInput.text = String(int(data0.level || 0) + 1);
         for(key0 in this.modifierToggles)
         {
            if(key0 == "modFreeTasksAndPurchases")
            {
               this.modifierToggleStates[key0] = Boolean(data0.modFreeTasksAndPurchases) || Boolean(data0.modPurchaseIgnoreConditions);
            }
            else
            {
               this.modifierToggleStates[key0] = key0 == "modInstantTaskComplete" && !data0.hasOwnProperty(key0) ? Boolean(data0.modFreeTasksAndPurchases) : data0.hasOwnProperty(key0) && Boolean(data0[key0]);
            }
            this.drawModifierToggle(this.modifierToggles[key0] as Sprite);
         }
         while(i0 < this.modifierSlotButtons.length)
         {
            button0 = this.modifierSlotButtons[i0] as Sprite;
            button0.alpha = button0.name == "modifierSlot_" + index0 ? 1 : 0.58;
            i0++;
         }
         this.setModifierControlsEnabled(true);
         this.modifierStatus.text = "已选择存档。修改只会在下次进入该存档时生效。";
      }

      private function drawModifierToggle(toggle0:Sprite) : void
      {
         var label0:TextField = toggle0.getChildByName("label") as TextField;
         var text0:String = label0.text.substr(3);
         label0.text = (Boolean(this.modifierToggleStates[toggle0.name]) ? "■  " : "□  ") + text0;
         label0.textColor = Boolean(this.modifierToggleStates[toggle0.name]) ? 65280 : 16777215;
      }

      private function setModifierControlsEnabled(enabled0:Boolean) : void
      {
         var key0:String = null;
         for(key0 in this.modifierToggles)
         {
            this.modifierToggles[key0].mouseEnabled = enabled0;
            this.modifierToggles[key0].alpha = enabled0 ? 1 : 0.4;
         }
      }

      private function saveModifierChanges() : void
      {
         var so0:SharedObject = null;
         var root0:Object = null;
         var slot0:Object = null;
         var key0:String = null;
         var displayLevel0:int = 0;
         try
         {
            if(this.modifierSelectedSlot < 0)
            {
               this.modifierStatus.text = "请先选择有效的存档槽位。";
               return;
            }
            so0 = SharedObject.getLocal("superalloy_mobile_save","/");
            root0 = so0.data.saveContainer;
            if(root0 == null || !(root0.localSlots is Array))
            {
               throw new Error("存档容器不存在");
            }
            slot0 = root0.localSlots[this.modifierSelectedSlot];
            if(slot0 == null || slot0.data == null)
            {
               throw new Error("选中的存档槽位已失效");
            }
            so0.data.lastGoodSave = this.cloneSaveObject(root0);
            displayLevel0 = int(this.modifierLevelInput.text);
            if(displayLevel0 < 1 || displayLevel0 > 999)
            {
               throw new Error("人物等级必须是1至999的整数");
            }
            slot0.data.level = displayLevel0 - 1;
            slot0.data.level2 = displayLevel0 - 1;
            for(key0 in this.modifierToggles)
            {
               slot0.data[key0] = Boolean(this.modifierToggleStates[key0]);
            }
            slot0.data.modPurchaseIgnoreConditions = Boolean(this.modifierToggleStates.modFreeTasksAndPurchases);
            if(this.modifierSelectedSlot == Game.gameData.nowSaveIndex)
            {
               Game.gameData.level = displayLevel0 - 1;
               Game.gameData.level2 = displayLevel0 - 1;
               for(key0 in this.modifierToggles)
               {
                  Game.gameData[key0] = Boolean(this.modifierToggleStates[key0]);
               }
               Game.gameData.modPurchaseIgnoreConditions = Boolean(this.modifierToggleStates.modFreeTasksAndPurchases);
               if(Game.uiGroup.mainUI != null && Game.uiGroup.mainUI.levelGift != null)
               {
                  Game.uiGroup.mainUI.levelGift.fleshData();
               }
            }
            if(Boolean(slot0.data.modNoTaskCooldown))
            {
               if(slot0.data.collectTaskData != null) slot0.data.collectTaskData.taskReadyAt = [];
               if(slot0.data.taskData != null) slot0.data.taskData.slotReadyAt = [0,0,0,0,0];
            }
            if(Boolean(slot0.data.modNoExtraCooldown) && slot0.data.extraData != null && slot0.data.extraData.cooldownReadyAt is Array)
            {
               i0ZeroArray(slot0.data.extraData.cooldownReadyAt as Array);
            }
            so0.data.saveContainer = root0;
            so0.flush();
            this.modifierStatus.text = this.modifierSelectedSlot == Game.gameData.nowSaveIndex ? "修改成功，当前存档已立即生效并建立恢复点。" : "修改成功，已自动建立恢复点。进入该存档后生效。";
         }
         catch(error:Error)
         {
            this.modifierStatus.text = "修改失败：" + error.message;
         }
      }

      private function i0ZeroArray(values0:Array) : void
      {
         var i0:int = 0;
         while(i0 < values0.length)
         {
            values0[i0] = 0;
            i0++;
         }
      }

      private function cloneSaveObject(value0:Object) : Object
      {
         var bytes0:ByteArray = new ByteArray();
         bytes0.writeObject(value0);
         bytes0.position = 0;
         return bytes0.readObject();
      }

      private function initSasaveContext() : void
      {
         this.sasaveBridgeReady = true;
         this.sasaveContextError = "";
      }

      private function createSasavePanel() : void
      {
         var title0:TextField = null;
         if(this.sasavePanel != null) return;
         this.sasavePanel = new Sprite();
         this.sasavePanel.graphics.beginFill(0,0.84);
         this.sasavePanel.graphics.drawRect(0,0,960,560);
         this.sasavePanel.graphics.endFill();
         this.sasavePanel.graphics.beginFill(329225,1);
         this.sasavePanel.graphics.lineStyle(3,65535,1);
         this.sasavePanel.graphics.drawRect(100,38,760,485);
         this.sasavePanel.graphics.endFill();
         title0 = this.createSaveDataText("存档交换",28,65535,true,760,42);
         title0.x = 100;
         title0.y = 55;
         this.sasavePanel.addChild(title0);
         this.sasaveStatus = this.createSaveDataText("",16,10092543,false,680,92);
         this.sasaveStatus.x = 140;
         this.sasaveStatus.y = 100;
         this.sasaveStatus.multiline = true;
         this.sasaveStatus.wordWrap = true;
         this.sasavePanel.addChild(this.sasaveStatus);
         this.sasaveConfirmButton = this.createSasaveCommand("确认","sasaveConfirm",590,465,110,38);
         this.sasavePanel.addChild(this.sasaveConfirmButton);
         this.sasavePanel.addChild(this.createSasaveCommand("取消","sasaveCancel",720,465,100,38));
         this.sasaveImportFileButton = this.createSasaveCommand("选择存档文件","sasaveImportFile",235,230,220,58);
         this.sasaveImportReceiveButton = this.createSasaveCommand("从其他软件接收","sasaveImportReceive",505,230,220,58);
         this.sasaveImportFileButton.visible = false;
         this.sasaveImportReceiveButton.visible = false;
         this.sasavePanel.addChild(this.sasaveImportFileButton);
         this.sasavePanel.addChild(this.sasaveImportReceiveButton);
         this.sasaveExportFileButton = this.createSasaveCommand("导出到文件","sasaveExportFile",330,420,145,38);
         this.sasaveExportShareButton = this.createSasaveCommand("分享到软件","sasaveExportShare",490,420,145,38);
         this.sasaveExportFileButton.visible = false;
         this.sasaveExportShareButton.visible = false;
         this.sasavePanel.addChild(this.sasaveExportFileButton);
         this.sasavePanel.addChild(this.sasaveExportShareButton);
         this.sasavePanel.visible = false;
         addChild(this.sasavePanel);
      }

      private function createSasaveCommand(text0:String, role0:String, x0:Number, y0:Number, width0:Number, height0:Number) : Sprite
      {
         var button0:Sprite = this.createSaveDataButton(text0,role0,x0,y0,width0,height0);
         button0.removeEventListener(MouseEvent.CLICK,this.saveDataPanelClick);
         button0.addEventListener(MouseEvent.CLICK,this.sasaveClick);
         return button0;
      }

      private function refreshSasaveSlots() : void
      {
         var old0:Sprite = null;
         var so0:SharedObject = SharedObject.getLocal("superalloy_mobile_save","/");
         var root0:Object = so0.data.saveContainer;
         var slots0:Array = root0 != null && root0.localSlots is Array ? root0.localSlots as Array : [];
         var visualNumbers0:Array = [2,3,1,4,5,6,7,8];
         var entries0:Array = [];
         var entry0:Object = null;
         var slot0:Object = null;
         var button0:Sprite = null;
         var i0:int = 0;
         while(this.sasaveSlotButtons.length > 0)
         {
            old0 = this.sasaveSlotButtons.pop() as Sprite;
            if(old0 != null && old0.parent == this.sasavePanel) this.sasavePanel.removeChild(old0);
         }
         while(i0 < 8)
         {
            slot0 = i0 < slots0.length ? slots0[i0] : null;
            if(this.sasaveMode == "import" || slot0 != null && slot0.data != null)
            {
               entries0.push({"index":i0,"number":int(visualNumbers0[i0]),"slot":slot0});
            }
            i0++;
         }
         entries0.sortOn("number",Array.NUMERIC);
         i0 = 0;
         while(i0 < entries0.length)
         {
            entry0 = entries0[i0];
            slot0 = entry0.slot;
            var label0:String = String(entry0.number) + "号";
            if(slot0 != null && slot0.data != null)
            {
               label0 += " " + String(slot0.data.playerName || "未知角色") + " Lv." + String(int(slot0.data.level || 0) + 1);
            }
            else
            {
               label0 += " 空槽位";
            }
            button0 = this.createSasaveCommand(label0,"sasaveSlot_" + String(entry0.index),135 + i0 % 2 * 350,205 + int(i0 / 2) * 55,330,42);
            this.sasaveSlotButtons.push(button0);
            this.sasavePanel.addChild(button0);
            i0++;
         }
         this.sasaveTargetIndex = -1;
         if(this.sasaveSlotButtons.length > 0)
         {
            this.selectSasaveSlot(int(String(this.sasaveSlotButtons[0].name).split("_")[1]));
         }
      }

      private function selectSasaveSlot(index0:int) : void
      {
         var i0:int = 0;
         var button0:Sprite = null;
         this.sasaveTargetIndex = index0;
         while(i0 < this.sasaveSlotButtons.length)
         {
            button0 = this.sasaveSlotButtons[i0] as Sprite;
            button0.alpha = button0.name == "sasaveSlot_" + index0 ? 1 : 0.55;
            i0++;
         }
      }

      private function consumeSharedSasave(openPicker0:Boolean = false) : void
      {
         var response0:Object = null;
         var slot0:Object = null;
         try
         {
            response0 = this.readNativeImportResult();
            if(response0 == null)
            {
               if(openPicker0)
               {
                  navigateToURL(new URLRequest("sasavebridge://import"),"_self");
                  this.sasaveStatus.text = "正在打开系统文件选择器，请选择.sasave存档文件。";
               }
               else
               {
                  this.showSasaveImportSources();
               }
               return;
            }
            if(response0.status != "ok") throw new Error(String(response0.message));
            this.sasaveManifest = response0.manifest;
            this.sasaveRisk = this.getSasaveVersionRisk(String(this.sasaveManifest.gameVersion));
            if(this.sasaveRisk < 0) throw new Error("该存档来自更高版本 " + String(this.sasaveManifest.gameVersion) + "，当前1.2版本禁止导入。请升级游戏。");
            slot0 = this.readSasaveSlot(String(response0.cachePath));
            this.validateSasaveSlot(slot0);
            this.sasavePendingSlot = slot0;
            this.sasaveMode = "import";
            this.sasaveImportFileButton.visible = false;
            this.sasaveImportReceiveButton.visible = false;
            this.sasaveConfirmButton.visible = true;
            this.refreshSasaveSlots();
            this.sasaveStatus.text = this.sasavePreviewText();
            this.sasavePanel.visible = true;
            setChildIndex(this.sasavePanel,numChildren - 1);
         }
         catch(error:Error)
         {
            this.saveDataStatus.text = "禁止导入：" + error.message;
         }
      }

      private function openSasaveExport() : void
      {
         this.sasaveMode = "export";
         this.sasaveImportFileButton.visible = false;
         this.sasaveImportReceiveButton.visible = false;
         this.sasaveConfirmButton.visible = true;
         this.sasaveExportFileButton.visible = false;
         this.sasaveExportShareButton.visible = false;
         this.sasavePendingSlot = null;
         this.sasaveManifest = null;
         this.refreshSasaveSlots();
         if(this.sasaveSlotButtons.length == 0)
         {
            this.saveDataStatus.text = "没有可导出的存档。";
            return;
         }
         this.sasaveStatus.text = "请选择要导出的存档槽位。导出文件为未加密的.sasave，可直接通过QQ或其他应用分享。";
         this.sasavePanel.visible = true;
         setChildIndex(this.sasavePanel,numChildren - 1);
      }

      private function sasaveClick(e:MouseEvent) : void
      {
         var role0:String = e.currentTarget.name;
         if(role0 == "sasaveCancel")
         {
            this.sasavePanel.visible = false;
            return;
         }
         if(role0.indexOf("sasaveSlot_") == 0)
         {
            this.selectSasaveSlot(int(role0.split("_")[1]));
            return;
         }
         if(role0 == "sasaveExportFile" || role0 == "sasaveExportShare")
         {
            this.launchNativeSasaveExport(role0 == "sasaveExportShare" ? "share" : "file");
            return;
         }
         if(role0 == "sasaveImportFile")
         {
            this.consumeSharedSasave(true);
            return;
         }
         if(role0 == "sasaveImportReceive")
         {
            this.sasaveStatus.text = "请前往QQ、微信或文件管理器，选择.sasave文件后点击“用其他应用打开”或“分享到其他应用”，再选择本游戏。返回游戏后再次点击导入存档。";
            return;
         }
         if(role0 == "sasaveConfirm")
         {
            if(this.sasaveMode == "import") this.importPendingSasave();
            else this.exportSelectedSasave();
         }
      }

      private function showSasaveImportSources() : void
      {
         var i0:int = 0;
         this.sasaveMode = "importSource";
         while(i0 < this.sasaveSlotButtons.length)
         {
            (this.sasaveSlotButtons[i0] as Sprite).visible = false;
            i0++;
         }
         this.sasaveExportFileButton.visible = false;
         this.sasaveExportShareButton.visible = false;
         this.sasaveConfirmButton.visible = false;
         this.sasaveImportFileButton.visible = true;
         this.sasaveImportReceiveButton.visible = true;
         this.sasaveStatus.text = "请选择存档来源。系统文件可直接选择；QQ、微信等软件中的文件需要从对应软件分享或用本游戏打开。";
         this.sasavePanel.visible = true;
         setChildIndex(this.sasavePanel,numChildren - 1);
      }

      private function importPendingSasave() : void
      {
         var so0:SharedObject = null;
         var root0:Object = null;
         if(this.sasaveTargetIndex < 0 || this.sasavePendingSlot == null)
         {
            this.sasaveStatus.text = "请选择目标槽位。";
            return;
         }
         try
         {
            so0 = SharedObject.getLocal("superalloy_mobile_save","/");
            root0 = so0.data.saveContainer;
            if(root0 == null) root0 = {"localSaveVersion":2,"localSlots":[]};
            if(!(root0.localSlots is Array)) root0.localSlots = [];
            so0.data.lastGoodSave = this.cloneSaveObject(root0);
            root0.localSlots[this.sasaveTargetIndex] = this.cloneSaveObject(this.sasavePendingSlot);
            so0.data.saveContainer = root0;
            so0.flush();
            this.sasaveStatus.text = "导入成功，已自动建立恢复点。请关闭界面后进入目标存档。";
            this.sasavePendingSlot = null;
         }
         catch(error:Error)
         {
            this.sasaveStatus.text = "导入失败：" + error.message;
         }
      }

      private function exportSelectedSasave() : void
      {
         var so0:SharedObject = null;
         var slot0:Object = null;
         var bytes0:ByteArray = null;
         var manifest0:Object = null;
         if(this.sasaveTargetIndex < 0) return;
         try
         {
            so0 = SharedObject.getLocal("superalloy_mobile_save","/");
            slot0 = so0.data.saveContainer.localSlots[this.sasaveTargetIndex];
            this.validateSasaveSlot(slot0);
            bytes0 = new ByteArray();
            bytes0.writeObject(slot0);
            bytes0.position = 0;
            manifest0 = {
               "format":"superalloy-save",
               "formatVersion":1,
               "gameVersion":"1.2.0",
               "playerName":String(slot0.data.playerName),
               "displayLevel":int(slot0.data.level || 0) + 1,
               "createdAt":new Date().time
            };
            this.sasaveExportFilePath = this.writeSasaveBridgeFile(bytes0);
            this.sasaveExportManifestPath = this.writeSasaveManifestFile(JSON2.encode(manifest0));
            this.sasaveExportName = String(slot0.data.playerName) + "-Lv" + String(int(slot0.data.level || 0) + 1) + ".sasave";
            this.sasaveExportFileButton.visible = true;
            this.sasaveExportShareButton.visible = true;
            this.sasaveStatus.text = "存档已准备完成，请选择导出到文件，或分享到其他软件。";
         }
         catch(error:Error)
         {
            this.sasaveStatus.text = "导出失败：" + error.message;
         }
      }

      private function writeSasaveBridgeFile(bytes0:ByteArray) : String
      {
         var fileClass0:Class = getDefinitionByName("flash.filesystem::File") as Class;
         var streamClass0:Class = getDefinitionByName("flash.filesystem::FileStream") as Class;
         var modeClass0:Class = getDefinitionByName("flash.filesystem::FileMode") as Class;
         var file0:* = fileClass0["applicationStorageDirectory"].resolvePath("sasave-export.bin");
         var stream0:* = new streamClass0();
         bytes0.position = 0;
         stream0.open(file0,modeClass0["WRITE"]);
         stream0.writeBytes(bytes0);
         stream0.close();
         return String(file0.nativePath);
      }

      private function writeSasaveManifestFile(text0:String) : String
      {
         var fileClass0:Class = getDefinitionByName("flash.filesystem::File") as Class;
         var streamClass0:Class = getDefinitionByName("flash.filesystem::FileStream") as Class;
         var modeClass0:Class = getDefinitionByName("flash.filesystem::FileMode") as Class;
         var file0:* = fileClass0["applicationStorageDirectory"].resolvePath("sasave-export.json");
         var stream0:* = new streamClass0();
         stream0.open(file0,modeClass0["WRITE"]);
         stream0.writeUTFBytes(text0);
         stream0.close();
         return String(file0.nativePath);
      }

      private function launchNativeSasaveExport(mode0:String) : void
      {
         var url0:String = "sasavebridge://" + mode0 + "?name=" + encodeURIComponent(this.sasaveExportName) + "&save=" + encodeURIComponent(this.sasaveExportFilePath) + "&manifest=" + encodeURIComponent(this.sasaveExportManifestPath);
         navigateToURL(new URLRequest(url0),"_self");
         this.sasaveStatus.text = mode0 == "share" ? "正在打开系统分享菜单。" : "正在打开系统文件保存界面。";
      }

      private function readNativeImportResult() : Object
      {
         var fileClass0:Class = getDefinitionByName("flash.filesystem::File") as Class;
         var streamClass0:Class = getDefinitionByName("flash.filesystem::FileStream") as Class;
         var modeClass0:Class = getDefinitionByName("flash.filesystem::FileMode") as Class;
         var file0:* = new fileClass0("/data/user/0/air.com.superalloy.metalwartale3.mobiletest/files/incoming-superalloy-save.json");
         if(!file0.exists) return null;
         var stream0:* = new streamClass0();
         stream0.open(file0,modeClass0["READ"]);
         var text0:String = stream0.readUTFBytes(stream0.bytesAvailable);
         stream0.close();
         file0.deleteFile();
         return JSON2.decode(text0);
      }

      private function readSasaveSlot(path0:String) : Object
      {
         var fileClass0:Class = getDefinitionByName("flash.filesystem::File") as Class;
         var streamClass0:Class = getDefinitionByName("flash.filesystem::FileStream") as Class;
         var modeClass0:Class = getDefinitionByName("flash.filesystem::FileMode") as Class;
         var file0:* = new fileClass0(path0);
         var stream0:* = new streamClass0();
         var bytes0:ByteArray = new ByteArray();
         stream0.open(file0,modeClass0["READ"]);
         stream0.readBytes(bytes0);
         stream0.close();
         bytes0.position = 0;
         return bytes0.readObject();
      }

      private function validateSasaveSlot(slot0:Object) : void
      {
         if(slot0 == null || slot0.data == null) throw new Error("文件内部不是本游戏存档槽位");
         if(!slot0.data.hasOwnProperty("playerName") || !slot0.data.hasOwnProperty("level")) throw new Error("存档缺少角色或等级数据");
         if(isNaN(Number(slot0.data.level)) || Number(slot0.data.level) < 0) throw new Error("存档等级数据不合法");
         if(!slot0.data.hasOwnProperty("carItems") || !slot0.data.hasOwnProperty("armsItems")) throw new Error("存档缺少必要的装备数据");
      }

      private function getSasaveVersionRisk(version0:String) : int
      {
         var source0:Array = this.parseSasaveVersion(version0);
         var current0:Array = [1,2,0];
         var i0:int = 0;
         while(i0 < 3)
         {
            if(int(source0[i0]) > int(current0[i0])) return -1;
            if(int(source0[i0]) < int(current0[i0])) return i0 == 0 ? 3 : (i0 == 1 ? 2 : 1);
            i0++;
         }
         return 0;
      }

      private function parseSasaveVersion(version0:String) : Array
      {
         var parts0:Array = version0.split(".");
         var result0:Array = [0,0,0];
         var i0:int = 0;
         if(parts0.length < 1 || parts0.length > 3) throw new Error("来源版本号格式不正确");
         while(i0 < parts0.length)
         {
            if(parts0[i0] == "" || isNaN(Number(parts0[i0])) || int(parts0[i0]) < 0) throw new Error("来源版本号格式不正确");
            result0[i0] = int(parts0[i0]);
            i0++;
         }
         return result0;
      }

      private function sasavePreviewText() : String
      {
         var warning0:String = "版本一致。";
         if(this.sasaveRisk == 1) warning0 = "小版本较旧，通常可以兼容。";
         else if(this.sasaveRisk == 2) warning0 = "警告：中版本较旧，导入后可能出现兼容问题。";
         else if(this.sasaveRisk == 3) warning0 = "高风险警告：大版本较旧，兼容性问题可能较大。";
         return "来源角色：" + String(this.sasavePendingSlot.data.playerName) + "　等级：" + String(int(this.sasavePendingSlot.data.level) + 1) + "　来源版本：" + String(this.sasaveManifest.gameVersion) + "\n" + warning0 + " 请选择覆盖槽位并点击确认。";
      }

      private function showImportPathNotice() : void
      {
         this.saveDataStatus.text = "本软件尚无应用私有文件夹访问权限，请使用支持访问私有目录的文件管理器自行打开。\n路径：/data/user/0/air.com.superalloy.metalwartale3.mobiletest/（可选择复制）";
      }

      private function chooseSaveDirectory(role0:String) : void
      {
         var fileClass:Class = null;
         try
         {
            fileClass = getDefinitionByName("flash.filesystem::File") as Class;
            this.clearSaveDirectoryBrowser();
            this.saveDirectoryRole = role0;
            this.saveDirectoryBrowser = new fileClass();
            this.saveDirectoryBrowser.addEventListener(Event.SELECT,this.saveDirectorySelected);
            this.saveDirectoryBrowser.addEventListener(Event.CANCEL,this.saveDirectoryCanceled);
            this.saveDirectoryBrowser.browseForDirectory(role0 == "backup" ? "设置存档备份目录" : "设置存档导出目录");
            this.saveDataStatus.text = role0 == "backup" ? "请选择备份目录。" : "请选择导出目录。";
         }
         catch(error:Error)
         {
            this.clearSaveDirectoryBrowser();
            this.saveDataStatus.text = "当前环境无法打开目录选择器。";
         }
      }

      private function saveDirectorySelected(e:Event) : void
      {
         var path0:String = this.saveDirectoryBrowser.nativePath;
         if(path0 == null || path0 == "")
         {
            path0 = this.saveDirectoryBrowser.url;
         }
         if(this.saveDirectoryRole == "backup")
         {
            this.backupDirectoryPath = path0;
            this.backupPathText.text = "备份路径：" + path0;
            this.saveDataStatus.text = "备份路径设置成功。";
            this.saveSaveDirectorySettings();
         }
         else if(this.saveDirectoryRole == "export")
         {
            this.exportDirectoryPath = path0;
            this.exportPathText.text = "导出路径：" + path0;
            this.saveDataStatus.text = "导出路径设置成功。";
            this.saveSaveDirectorySettings();
         }
         this.clearSaveDirectoryBrowser();
      }

      private function saveDirectoryCanceled(e:Event) : void
      {
         this.saveDataStatus.text = "已取消选择目录。";
         this.clearSaveDirectoryBrowser();
      }

      private function clearSaveDirectoryBrowser() : void
      {
         if(this.saveDirectoryBrowser != null)
         {
            this.saveDirectoryBrowser.removeEventListener(Event.SELECT,this.saveDirectorySelected);
            this.saveDirectoryBrowser.removeEventListener(Event.CANCEL,this.saveDirectoryCanceled);
         }
         this.saveDirectoryBrowser = null;
         this.saveDirectoryRole = "";
      }

      private function openSavedDirectory(path0:String, emptyMessage0:String) : void
      {
         var fileClass:Class = null;
         var directory0:* = null;
         if(path0 == "")
         {
            this.saveDataStatus.text = emptyMessage0;
            return;
         }
         try
         {
            fileClass = getDefinitionByName("flash.filesystem::File") as Class;
            directory0 = new fileClass(path0);
            directory0.openWithDefaultApplication();
            this.saveDataStatus.text = "正在打开已设置的目录。";
         }
         catch(error:Error)
         {
            this.saveDataStatus.text = "目录无法打开，请重新设置。";
         }
      }

      private function loadSaveDirectorySettings() : void
      {
         var settings0:SharedObject = null;
         try
         {
            settings0 = SharedObject.getLocal("superalloy_save_directories","/");
            this.backupDirectoryPath = settings0.data.backupPath == null ? "" : String(settings0.data.backupPath);
            this.exportDirectoryPath = settings0.data.exportPath == null ? "" : String(settings0.data.exportPath);
         }
         catch(error:Error)
         {
            this.backupDirectoryPath = "";
            this.exportDirectoryPath = "";
         }
         this.backupPathText.text = this.backupDirectoryPath == "" ? "备份路径：尚未设置" : "备份路径：" + this.backupDirectoryPath;
         this.exportPathText.text = this.exportDirectoryPath == "" ? "导出路径：尚未设置" : "导出路径：" + this.exportDirectoryPath;
      }

      private function saveSaveDirectorySettings() : void
      {
         try
         {
            var settings0:SharedObject = SharedObject.getLocal("superalloy_save_directories","/");
            settings0.data.backupPath = this.backupDirectoryPath;
            settings0.data.exportPath = this.exportDirectoryPath;
            settings0.flush();
         }
         catch(error:Error)
         {
            this.saveDataStatus.text = "路径已选择，但设置保存失败。";
         }
      }

      private function hideMainMenuNoticeBadge() : void
      {
         var i:int = 0;
         var child:DisplayObject = null;
         while(i < this.numChildren)
         {
            child = this.getChildAt(i);
            if(Math.abs(child.x - 425) < 1 && Math.abs(child.y - 153) < 1 && child.width >= 20 && child.width <= 35 && child.height >= 20 && child.height <= 35)
            {
               child.visible = false;
               return;
            }
            i++;
         }
      }

      private function createOfflineNotice() : Sprite
      {
         var box:Sprite = new Sprite();
         this.notice_txt = new TextField();
         this.notice_txt.width = 455;
         this.notice_txt.height = 210;
         this.notice_txt.multiline = true;
         this.notice_txt.wordWrap = true;
         this.notice_txt.selectable = false;
         this.notice_txt.defaultTextFormat = new TextFormat("_sans",13,65331,null,null,null,null,null,null,0,0,3,2);
         this.notice_txt.text = "【超合金战记手游 1.2.5 更新】\n火神炮能量与射速机制还原 · 武器菜单一律可开（含关卡内）· 新美术武器挂点标记全隐藏 · 感应炮激光出射修正 · 新手教程与守望者音效修复 · 修改器冷却链与全解锁直通。";
         box.addChild(this.notice_txt);
         return box;
      }
      
      private function loadOfflineNotice() : void
      {
         this.noticeLoader = new URLLoader();
         this.noticeLoader.dataFormat = URLLoaderDataFormat.TEXT;
         this.noticeLoader.addEventListener(Event.COMPLETE,this.offlineNoticeLoaded);
         this.noticeLoader.addEventListener(IOErrorEvent.IO_ERROR,this.offlineNoticeLoadFailed);
         this.noticeLoader.load(new URLRequest("游戏更新公告.txt?time=" + new Date().time));
      }

      private function loadGameNotice() : void
      {
         this.gameNoticeLoader = new URLLoader();
         this.gameNoticeLoader.dataFormat = URLLoaderDataFormat.TEXT;
         this.gameNoticeLoader.addEventListener(Event.COMPLETE,this.gameNoticeLoaded);
         this.gameNoticeLoader.addEventListener(IOErrorEvent.IO_ERROR,this.gameNoticeLoadFailed);
         this.gameNoticeLoader.load(new URLRequest("感谢公告.txt?time=" + new Date().time));
      }

      private function gameNoticeLoaded(event:Event) : void
      {
         var text0:String = String(this.gameNoticeLoader.data);
         if(text0.length > 0 && text0.charCodeAt(0) == 65279)
         {
            text0 = text0.substr(1);
         }
         if(text0.length > 0)
         {
            this.txt1.htmlText = text0;
         }
         this.clearGameNoticeLoader();
      }

      private function gameNoticeLoadFailed(event:IOErrorEvent) : void
      {
         this.clearGameNoticeLoader();
      }

      private function clearGameNoticeLoader() : void
      {
         if(this.gameNoticeLoader != null)
         {
            this.gameNoticeLoader.removeEventListener(Event.COMPLETE,this.gameNoticeLoaded);
            this.gameNoticeLoader.removeEventListener(IOErrorEvent.IO_ERROR,this.gameNoticeLoadFailed);
            this.gameNoticeLoader = null;
         }
      }
      
      private function offlineNoticeLoaded(event:Event) : void
      {
         var text0:String = String(this.noticeLoader.data);
         if(text0.length > 0 && text0.charCodeAt(0) == 65279)
         {
            text0 = text0.substr(1);
         }
         if(this.notice_txt != null && text0.length > 0)
         {
            this.notice_txt.text = text0;
            this.notice_txt.height = this.notice_txt.textHeight + 6;
            if(this.sBar != null && this.context_mc != null)
            {
               this.sBar.setTarget(this.context_mc,false);
               this.sBar.setPer(0);
            }
         }
         this.clearNoticeLoader();
      }

      private function scrollOfflineNotice(event:MouseEvent) : void
      {
         var scrollRange:Number = 0;
         if(this.sBar == null || this.context_mc == null)
         {
            return;
         }
         scrollRange = this.context_mc.height + 30 - this.sBar.limitHigh;
         if(scrollRange <= 0)
         {
            return;
         }
         this.sBar.setPer(this.sBar.getPer() - event.delta * 36 / scrollRange);
         event.stopPropagation();
      }
      
      private function offlineNoticeLoadFailed(event:IOErrorEvent) : void
      {
         this.clearNoticeLoader();
      }
      
      private function clearNoticeLoader() : void
      {
         if(this.noticeLoader != null)
         {
            this.noticeLoader.removeEventListener(Event.COMPLETE,this.offlineNoticeLoaded);
            this.noticeLoader.removeEventListener(IOErrorEvent.IO_ERROR,this.offlineNoticeLoadFailed);
            this.noticeLoader = null;
         }
      }
      
      public function InitSelect() : void
      {
         var i:int = 1;
         while(i < 9)
         {
            (this["btn_" + i] as MovieClip).gotoAndStop(1);
            (this["btn_" + i] as MovieClip).buttonMode = true;
            (this["btn_" + i] as MovieClip).mouseChildren = false;
            (this["name_" + i] as MovieClip).mouseEnabled = false;
            (this["name_" + i] as MovieClip).mouseChildren = false;
            (this["name_" + i]["txt_name"] as TextField).text = "无角色数据";
            (this["name_" + i]["txt_level"] as TextField).text = "";
            (this["name_" + i]["txt_date"] as TextField).text = "";
            (this["btn_" + i] as MovieClip).addEventListener(MouseEvent.CLICK,this.onSelectClick);
            i++;
         }
         (this["btn_back"] as SimpleButton).addEventListener(MouseEvent.CLICK,this.onGoTo1);
      }
      
      protected function onGoTo1(event:MouseEvent) : void
      {
         this.InitSever();
      }
      
      private function getindex(id:int) : int
      {
         switch(id)
         {
            case 2:
               return 0;
            case 3:
               return 1;
            case 1:
               return 2;
            case 4:
               return 3;
            case 5:
               return 4;
            case 6:
               return 5;
            case 7:
               return 6;
            case 8:
               return 7;
            default:
               return 7;
         }
      }
      
      private function getid(id:int) : int
      {
         switch(id)
         {
            case 0:
               return 2;
            case 1:
               return 3;
            case 2:
               return 1;
            case 3:
               return 4;
            case 4:
               return 5;
            case 5:
               return 6;
            case 6:
               return 7;
            case 7:
               return 8;
            default:
               return 8;
         }
      }
      
      public function SetSave(data:Array) : void
      {
         var i:* = undefined;
         var obj:Object = null;
         var tmpStr:String = null;
         var name:String = null;
         var lv:String = null;
         var tarr:Array = null;
         this.gotoAndStop(2);
         this.InitSelect();
         if(data == null)
         {
            return;
         }
         var j:int = 1;
         for(i in data)
         {
            obj = data[i];
            if(obj != null)
            {
               j = this.getid(obj.index);
               if(this["btn_" + j] as MovieClip != null)
               {
                  tmpStr = "存档的位置:" + obj.index + "存档时间:" + obj.datetime + "存档标题:" + obj.title + "存档状态:" + obj.status;
                  trace(tmpStr);
                  name = "";
                  lv = "";
                  tarr = obj.title.split("_");
                  if(tarr.length > 1)
                  {
                     lv = tarr[tarr.length - 1];
                     tarr.pop();
                  }
                  name = tarr.join("_");
                  (this["btn_" + j] as MovieClip).gotoAndStop(1);
                  (this["btn_" + j] as MovieClip).buttonMode = true;
                  (this["btn_" + j] as MovieClip).mouseChildren = false;
                  (this["name_" + j] as MovieClip).mouseEnabled = false;
                  (this["name_" + j] as MovieClip).mouseChildren = false;
                  (this["name_" + j]["txt_name"] as TextField).text = "" + name;
                  (this["name_" + j]["txt_level"] as TextField).text = "LV " + (int(lv) + 1);
                  (this["name_" + j]["txt_date"] as TextField).text = "" + obj.datetime;
                  (this["btn_" + j] as MovieClip).objindex = obj.index;
               }
            }
         }
      }
      
      protected function onSelectClick(event:MouseEvent) : void
      {
         var mc:MovieClip = event.currentTarget as MovieClip;
         var name:String = mc.name;
         var id:int = int(name.split("_")[1]);
         var i:int = 1;
         while(i < 9)
         {
            (this["btn_" + i] as MovieClip).gotoAndStop(1);
            i++;
         }
         mc.gotoAndStop(2);
         this._selectIdex = mc["objindex"] != null ? int(mc["objindex"]) : this.getindex(id);
         if(mc["objindex"] != null)
         {
            if(this._isnew)
            {
               Game.uiGroup.checkTip.showCheck("是否要覆盖旧的存档?",this.yesfuncover,this.nofun);
            }
            else
            {
               this.yesfun();
            }
         }
         else if(this._isnew)
         {
            Game.uiGroup.checkTip.showCheck("是否要创建新的存档?",this.yesfun,this.nofun);
         }
         else
         {
            Game.uiGroup.checkTip.showCheck("该位置无存档,是否要创建?",this.yesfun,this.nofun);
         }
         trace("选择关卡存档:" + id);
      }
      
      public function getSelectData() : StringDate
      {
         return this._selectSaveData;
      }
      
      private function yesfuncover() : void
      {
         Game.gameData.nowSaveIndex = this._selectIdex;
         this.hide();
         if(this.fun2 is Function)
         {
            this.fun2(true);
         }
      }
      
      private function yesfun() : void
      {
         var hasData:Boolean = false;
         Game.gameData.nowSaveIndex = this._selectIdex;
         if(Boolean(this["name_" + this.getid(this._selectIdex)]) && Boolean((this["name_" + this.getid(this._selectIdex)]["txt_date"] as TextField).text))
         {
            hasData = true;
            this._selectSaveData = new StringDate();
            this._selectSaveData.inData_byStr((this["name_" + this.getid(this._selectIdex)]["txt_date"] as TextField).text);
         }
         this.hide();
         if(this.fun2 is Function)
         {
            this.fun2(!hasData);
         }
      }
      
      private function nofun() : void
      {
      }
      
      protected function hideIntro(event:MouseEvent) : void
      {
         this.intro_mc.visible = false;
      }
      
      protected function hideProducer(event:MouseEvent) : void
      {
         this.producer_mc.visible = false;
      }
      
      protected function gotomake(event:MouseEvent) : void
      {
         this.producer_mc.visible = true;
      }
      
      protected function gotointro(event:MouseEvent) : void
      {
         this.intro_mc.visible = true;
      }
      
      protected function gotocontinue(event:MouseEvent) : void
      {
         this._isnew = false;
         if(this.fun is Function)
         {
            this.fun();
         }
      }
      
      protected function gotonew(event:MouseEvent) : void
      {
         this._isnew = true;
         if(this.fun is Function)
         {
            this.fun();
         }
      }
      
      public function click(e:*) : *
      {
         var index0:int = int(String(e.target.name).split("_")[1]);
         Game.gameData.nowSaveIndex = index0;
         this.hide();
         if(this.fun is Function)
         {
            this.fun();
         }
      }
      
      public function gotoBBS(e:*) : *
      {
         navigateToURL(new URLRequest("http://my.4399.com/forums-mtag-tagid-81243.html"),"_blank");
      }
      
      public function show(fun0:Function = null, fun1:Function = null) : *
      {
         this.fun = fun0;
         this.fun2 = fun1;
         this.visible = true;
         this._selectSaveData = null;
         Game.uiGroup.faseUI.clearLogo();
         Game.uiGroup.faseUI.StopGame();
      }
      
      public function hide() : *
      {
         this.visible = false;
         Game.uiGroup.faseUI.resumeLogo();
      }
   }
}

