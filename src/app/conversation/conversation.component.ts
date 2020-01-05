import { Component, OnInit, ViewChild, ElementRef } from '@angular/core';
import { ConversationService, Message } from './conversation.service';

@Component({
  selector: 'hap-conversation',
  templateUrl: './conversation.component.html',
  styleUrls: ['./conversation.component.scss']
})
export class ConversationComponent implements OnInit {

  @ViewChild('wrapper', {static: true}) wrapper: ElementRef

  conversation: Message[] = []

  constructor(private conversationService: ConversationService) { }

  ngOnInit() {
    this.conversationService.conversation
      .subscribe(messages => {
        this.conversation = messages
        this.scrollIntoView()
      })
  }

  private scrollIntoView() {
    const wrapperEl = this.wrapper.nativeElement
    wrapperEl.scrollTop = wrapperEl.scrollHeight
  }
}
