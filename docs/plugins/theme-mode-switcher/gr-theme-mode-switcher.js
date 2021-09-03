

$.fn.hasAttr = function(name) {  
  return this.attr(name) !== undefined;
};

//Theme Switcher Panel
const mode_panel_init= () => {
  var activation = $('body').hasAttr('data-theme-mode-panel-active');
    // console.log(activation);
    let bodyactive = $('body').attr('data-theme');
    let defaultActive = (bodyactive == 'light' || bodyactive == undefined);
  if(activation){
    $('body').append(`
    <div class="position-fixed-right mode-switcher-panel-wrapper">
    <div class="position-relative mode-switcher-panel">
      <span class="text">
        Change Version
      </span>
      <div class="buttons">
        <button class="${defaultActive && 'active'} switcher-btn" data-theme-mode="light">
          Light
        </button>
        <button class="${bodyactive == 'dark' && 'active'} switcher-btn" data-theme-mode="dark">
          dark
        </button>
      </div>
      <button class="switcher-minimize-button">
        <i class="icon icon-small-left"></i>
      </button>
    </div>
  </div>
    `)
  }
  
  
}

const mode_panel_activities = () => {
  $('.mode-switcher-panel').on("click",function(e){
    let button = document.querySelectorAll('.switcher-btn');
    let buttonPanel = document.querySelector('.switcher-minimize-button');
    button.forEach((btnItem) => {
      if(e.target == btnItem){
        e.target.classList.add('active');
        $(e.target).siblings().removeClass('active');
        let selectedMode = $('.switcher-btn.active').attr('data-theme-mode');
        $('body').attr('data-theme' , selectedMode);
      }
    })
    // console.log(e.target)
    if(e.target == buttonPanel){
      $('body').toggleClass("theme-mode-panel-open");
      if($('body').hasClass("theme-mode-panel-open")){
        $(e.target).addClass("open");
      }else{
        $(e.target).removeClass("open");
      }
    }
  
  })
}
$(document).ready(function(){

  
  mode_panel_init();
  mode_panel_activities();
  
})