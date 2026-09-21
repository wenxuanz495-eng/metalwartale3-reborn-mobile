package
{
   import flash.display.Loader;
   import flash.display.LoaderInfo;
   import flash.display.Sprite;
   import flash.events.ErrorEvent;
   import flash.events.Event;
   import flash.events.IOErrorEvent;
   import flash.filesystem.File;
   import flash.filesystem.FileMode;
   import flash.filesystem.FileStream;
   import flash.system.ApplicationDomain;
   import flash.system.LoaderContext;
   import flash.text.TextField;
   import flash.text.TextFormat;
   import flash.utils.ByteArray;

   // 对照探针(20260923): 与 AirLoader 唯一差异是不加载 patch.swf——直接加载
   // FFDec 链完整产物 game.swf(原厂字节码,含 3.0.4 全部补丁与内容)。
   // 用于分离"双 SWF 加载结构"与"mxmlc 重编译字节码"两个变量的性能贡献。
   public class AirLoaderProbe extends Sprite
   {
      private var status:TextField;

      public function AirLoaderProbe()
      {
         this.status = new TextField();
         this.status.defaultTextFormat = new TextFormat("_sans",14,16777215);
         this.status.background = true;
         this.status.backgroundColor = 0;
         this.status.width = 800;
         this.status.height = 24;
         this.status.text = "probe: loading...";
         addChild(this.status);
         this.load();
      }

      private function readAppFile(name:String) : ByteArray
      {
         var stream:FileStream = new FileStream();
         stream.open(File.applicationDirectory.resolvePath(name),FileMode.READ);
         var bytes:ByteArray = new ByteArray();
         stream.readBytes(bytes);
         stream.close();
         return bytes;
      }

      private function load() : void
      {
         var loader:Loader = new Loader();
         var context:LoaderContext = new LoaderContext(false,ApplicationDomain.currentDomain);
         context.allowCodeImport = true;
         loader.contentLoaderInfo.addEventListener(Event.COMPLETE,this.onComplete);
         loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR,this.onError);
         loader.loadBytes(this.readAppFile("game.swf"),context);
      }

      private function onComplete(event:Event) : void
      {
         var loader:Loader = (event.target as LoaderInfo).loader;
         this.status.visible = false;
         addChildAt(loader,0);
      }

      private function onError(event:ErrorEvent) : void
      {
         this.status.text = "probe FAILED: " + event.text;
      }
   }
}
