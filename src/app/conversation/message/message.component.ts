import { Component, OnInit, Input, ViewChild, ViewContainerRef, AfterViewInit, AfterContentInit, ComponentFactoryResolver } from '@angular/core';
import { Message } from '../conversation.service';
import { ShowEntryMessageComponent } from '../show-entry-message/show-entry-message.component';
import { InputQueryMessageComponent } from '../input-query-message/input-query-message.component';
import { AddEntryMessageComponent } from '../add-entry-message/add-entry-message.component';

@Component({
  selector: 'hap-message',
  templateUrl: './message.component.html',
  styleUrls: ['./message.component.scss']
})
export class MessageComponent implements OnInit, AfterContentInit {

  @ViewChild('entryComponent', {static: true, read: ViewContainerRef})
  entry: ViewContainerRef;

  @Input() message: Message

  constructor(
    private resolver: ComponentFactoryResolver
  ) { }

  ngOnInit() {
  }

  ngAfterContentInit() {
    if (!this.message.data.name) return;

    let componentResolved = null

    switch(this.message.data.name) {
      case 'input-query':
        componentResolved = InputQueryMessageComponent;
        break;

      case 'new-entry':
        componentResolved = AddEntryMessageComponent;
        break;

      case 'see-before':
        componentResolved = ShowEntryMessageComponent;
        break;

      default:
        componentResolved = ShowEntryMessageComponent;
        break;
    }

    const xfactory = this.resolver.resolveComponentFactory(componentResolved)
    const componentRef = this.entry.createComponent(xfactory);
    (<any>componentRef.instance).data = this.message;
  }

}
