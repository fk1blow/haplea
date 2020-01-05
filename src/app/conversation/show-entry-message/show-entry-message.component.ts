import { Component, OnInit, Input } from '@angular/core';

@Component({
  selector: 'hap-show-entry-message',
  templateUrl: './show-entry-message.component.html',
  styleUrls: ['./show-entry-message.component.scss']
})
export class ShowEntryMessageComponent implements OnInit {

  @Input() data: Record<string, any>

  constructor() { }

  ngOnInit() {
  }

}
