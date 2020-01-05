import { Component, OnInit, Input } from '@angular/core';

@Component({
  selector: 'hap-input-query-message',
  templateUrl: './input-query-message.component.html',
  styleUrls: ['./input-query-message.component.scss']
})
export class InputQueryMessageComponent implements OnInit {

  @Input() data: Record<string, any>

  constructor() { }

  ngOnInit() {
  }

}
