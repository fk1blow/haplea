import { Subject } from 'rxjs';
import { debounceTime } from 'rxjs/operators';

import {
    AfterViewInit, Component, ElementRef, EventEmitter, OnInit, Output, ViewChild
} from '@angular/core';

@Component({
  selector: 'hap-commander',
  templateUrl: './commander.component.html',
  styleUrls: ['./commander.component.scss']
})
export class CommanderComponent implements OnInit, AfterViewInit {

  @Output() changed = new EventEmitter<string>()

  @ViewChild('input', { static: false }) commanderInput: ElementRef

  constructor() {
  }

  ngOnInit() {
  }

  ngAfterViewInit() {
    this.commanderInput.nativeElement.focus()
  }

  onCommandSubmit(evt: Event) {
    evt.preventDefault()
    this.changed.emit(this.commanderInput.nativeElement.value)
  }

}
