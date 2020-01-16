import { Injectable } from '@angular/core';
import { BehaviorSubject } from 'rxjs';
import { skip } from 'rxjs/operators';
import { HttpClient } from '@angular/common/http';

import  { Socket } from 'phoenix-channels'

export interface Message {
  id: number
  body: string
  data: Record<string, any>
}

type ConversationInput = string

@Injectable({
  providedIn: 'root'
})
export class ConversationService {

  private socket = new Socket("ws://localhost:4000/socket")

  private lobbyChannel = this.socket.channel('room:lobby', {})

  get conversation() {
    return this.messages$.pipe(skip(1))
  }

  private messages$ = new BehaviorSubject<Message[]>([])

  constructor(private http: HttpClient) {
    this.socket.connect()

    this.lobbyChannel.join()
      .receive("ok", resp => console.log("Joined successfully", resp))
      .receive("error", resp => console.log("Unable to join", resp))

    this.lobbyChannel.on('conversation:message:posted', (message) => {
      this.messages$.next([
        message,
        ...this.messages$.value
      ])
    })

    this.lobbyChannel.on('conversation:message:post_error', err => {
      console.error('post_error: ', err)
    })

    this.lobbyChannel.on('question:thread:error', err => {
      console.error('err: ', err);
    })
  }

  // there should be a different service that handles the ws connection
  // and this one should communicate with it insted of directly sending messages
  push(input: ConversationInput) {
    this.lobbyChannel.push('conversation:message:post', { body: input })
  }

  pushNewEntry(input: string) {
    this.lobbyChannel.push('conversation:expense:create', { body: input })
  }

}
