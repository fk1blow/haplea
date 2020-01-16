import { Component, OnInit, Input } from '@angular/core';
import { ConversationService, ConversationMessage } from '../conversation.service';
import { get as _get } from 'lodash'

@Component({
  selector: 'hap-add-entry-message',
  templateUrl: './add-entry-message.component.html',
  styleUrls: ['./add-entry-message.component.scss']
})
export class AddEntryMessageComponent implements OnInit {

  @Input() value: ConversationMessage

  entryInput = ''

  constructor(private conversationService: ConversationService) { }

  ngOnInit() {
    console.log('this.value: ', this.value);
  }

  onSubmit(evt: Event) {
    evt.preventDefault()
  }

  onAdd(evt: Event) {
    evt.preventDefault()

    const datetime: { value: string } =
      _get(this.value.data.entities.datetime, 0, {value: new Date()})

    if (this.entryInput.trim().length > 0)
      this.conversationService.pushNewEntry({
        input: this.entryInput,
        atDate: datetime.value
      })
  }

}
