package data
{
   import flash.display.*;
   import flash.events.ContextMenuEvent;
   import flash.net.*;
   import flash.ui.*;
   
   public class Copyright
   {
      
      private var myName:String = "游戏公国版权所有";
      
      private var myUrl:String = "#";
      
      private var target:InteractiveObject;
      
      public function Copyright(target:InteractiveObject)
      {
         super();
         this.target = target;
         this.removeAndAddItem();
      }
      
      private function removeAndAddItem() : void
      {
         var myContextMenu:ContextMenu = null;
         try
         {
            if(this.target == null)
            {
               return;
            }
            myContextMenu = new ContextMenu();
            myContextMenu.hideBuiltInItems();
            if(myContextMenu.customItems == null)
            {
               return;
            }
            myContextMenu.customItems.push(new ContextMenuItem(this.myName));
            myContextMenu.customItems.push(new ContextMenuItem(Game.versionNumber));
            this.target.contextMenu = myContextMenu;
         }
         catch(error:Error)
         {
         }
      }
      
      private function itemSelectHandler(e:ContextMenuEvent) : void
      {
      }
   }
}

