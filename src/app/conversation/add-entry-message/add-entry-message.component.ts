import { Component, OnInit } from '@angular/core';
import { ConversationService } from '../conversation.service';

@Component({
  selector: 'hap-add-entry-message',
  templateUrl: './add-entry-message.component.html',
  styleUrls: ['./add-entry-message.component.scss']
})
export class AddEntryMessageComponent implements OnInit {

  entryInput = ''

  constructor(private conversationService: ConversationService) { }

  ngOnInit() {
  }

  onSubmit(evt: Event) {
    evt.preventDefault()
  }

  onAdd(evt: Event) {
    evt.preventDefault()

    if (this.entryInput.trim().length > 0)
      this.conversationService.pushNewEntry(this.entryInput)
  }

}
