package
{
   import flash.display.Loader;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.external.ExtensionContext;
   import flash.net.SharedObject;
   import flash.system.ApplicationDomain;
   import flash.system.LoaderContext;
   import flash.utils.ByteArray;
   import flash.filesystem.File;
   import flash.filesystem.FileMode;
   import flash.filesystem.FileStream;

   public class MobileBootstrap extends Sprite
   {
      [Embed(source="../stage/game.swf",mimeType="application/octet-stream")]
      private static const GameBytes:Class;

      private var context:ExtensionContext;

      private var gameLoader:Loader;

      public function MobileBootstrap()
      {
         var loaderContext:LoaderContext = null;
         super();
         this.initializeBridge();
         this.gameLoader = new Loader();
         addChild(this.gameLoader);
         this.gameLoader.contentLoaderInfo.addEventListener(Event.COMPLETE,this.gameLoaded);
         loaderContext = new LoaderContext(false,new ApplicationDomain(ApplicationDomain.currentDomain));
         loaderContext.allowCodeImport = true;
         this.gameLoader.loadBytes(new GameBytes() as ByteArray,loaderContext);
      }

      private function initializeBridge() : void
      {
         var bridge:SharedObject = SharedObject.getLocal("superalloy_sasave_bridge","/");
         try
         {
            this.context = ExtensionContext.createExtensionContext("com.superalloy.sasave",null);
            bridge.data.ready = this.context != null;
            bridge.data.error = this.context == null ? "无法创建原生扩展上下文" : "";
         }
         catch(error:Error)
         {
            bridge.data.ready = false;
            bridge.data.error = error.message;
         }
         bridge.flush();
      }

      private function gameLoaded(event:Event) : void
      {
         this.gameLoader.content.addEventListener("sasaveConsumeRequest",this.consumeRequest);
         this.gameLoader.content.addEventListener("sasaveExportRequest",this.exportRequest);
      }

      private function consumeRequest(event:Event) : void
      {
         var bridge:SharedObject = SharedObject.getLocal("superalloy_sasave_bridge","/");
         try
         {
            bridge.data.importResult = String(this.context.call("consumeIncoming"));
         }
         catch(error:Error)
         {
            bridge.data.importResult = this.errorResult(error.message);
         }
         bridge.flush();
      }

      private function exportRequest(event:Event) : void
      {
         var bridge:SharedObject = SharedObject.getLocal("superalloy_sasave_bridge","/");
         var stream:FileStream = null;
         var bytes:ByteArray = new ByteArray();
         try
         {
            stream = new FileStream();
            stream.open(new File(String(bridge.data.exportFile)),FileMode.READ);
            stream.readBytes(bytes);
            stream.close();
            bridge.data.exportResult = String(this.context.call("shareSave",bytes,String(bridge.data.exportManifest),String(bridge.data.exportName)));
         }
         catch(error:Error)
         {
            if(stream != null) try { stream.close(); } catch(closeError:Error) {}
            bridge.data.exportResult = this.errorResult(error.message);
         }
         bridge.flush();
      }

      private function errorResult(message:String) : String
      {
         return "{\"status\":\"error\",\"message\":\"" + message.split("\\").join("\\\\").split("\"").join("\\\"").split("\r").join(" ").split("\n").join(" ") + "\"}";
      }
   }
}
