import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    document.onkeydown = this.handleKey.bind(this);
  }

  handleKey(e) {
    let action = '';

    if (e.keyCode == '38') {
      e.preventDefault();
      e.stopPropagation();

      action = 'rotate';
    } else if (e.keyCode == '40') {
      e.preventDefault();
      e.stopPropagation();

      return false;
    } else if (e.keyCode == '37') {
      action = 'move_left';
    } else if (e.keyCode == '39') {
      action = 'move_right';
    }

    if (!action) {
      return;
    }

    let xhr = new XMLHttpRequest();

    let url = '/games/' + action;

    xhr.open("GET", url, true);
    xhr.send();
  }
}
