import {
    AfterContentInit, Component, ComponentFactoryResolver, Input, OnInit, ViewChild,
    ViewContainerRef
} from '@angular/core';

import { AddEntryMessageComponent } from '../add-entry-message/add-entry-message.component';
import { Message } from '../conversation.service';
import { InputQueryMessageComponent } from '../input-query-message/input-query-message.component';
import {
    SeeBeforeRelativeMessageComponent
} from '../see-before-relative-message/see-before-relative-message';
import { SeeYesterdatMessageComponent } from '../see-yesterday-message/see-yesterday.component';

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

      case 'see-before-relative':
        componentResolved = SeeBeforeRelativeMessageComponent;
        break;

      case 'see-yesterday':
        componentResolved = SeeYesterdatMessageComponent;
        break;

      case 'undefined-intent':
        console.log('undefined intent')
        break;

      default:
        console.log('undefined intent')
        // componentResolved = ShowEntryMessageComponent;
        break;
    }

    if (!componentResolved) return;

    const xfactory = this.resolver.resolveComponentFactory(componentResolved)
    const componentRef = this.entry.createComponent(xfactory);
    (componentRef.instance as any).value = this.message;
  }

}
