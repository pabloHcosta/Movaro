import { HttpStatus } from '@nestjs/common';

import { AppException } from './app-exception';
import { ErrorCode } from './error-code.enum';

export class AppErrorFactory {
  static cityNotFound(cityId: string): AppException {
    return new AppException({
      code: ErrorCode.CityNotFound,
      status: HttpStatus.NOT_FOUND,
      message: `City "${cityId}" was not found in the Movaro catalog.`,
      userMessage: 'Nao encontramos essa cidade no catalogo atual do Movaro.',
    });
  }

  static validationError(
    message: string,
    userMessage = 'Revise os dados enviados e tente novamente.',
  ): AppException {
    return new AppException({
      code: ErrorCode.ValidationError,
      status: HttpStatus.BAD_REQUEST,
      message,
      userMessage,
    });
  }

  static unauthorized(
    message = 'Authentication is required.',
    userMessage = 'Voce precisa entrar para continuar essa acao.',
  ): AppException {
    return new AppException({
      code: ErrorCode.Unauthorized,
      status: HttpStatus.UNAUTHORIZED,
      message,
      userMessage,
    });
  }

  static resourceNotFound(
    resource: string,
    userMessage = 'Nao encontramos o recurso solicitado.',
  ): AppException {
    return new AppException({
      code: ErrorCode.ResourceNotFound,
      status: HttpStatus.NOT_FOUND,
      message: `${resource} was not found.`,
      userMessage,
    });
  }

  static networkError(
    message: string,
    userMessage = 'Nao foi possivel consultar uma fonte externa agora. Tente novamente.',
  ): AppException {
    return new AppException({
      code: ErrorCode.NetworkError,
      status: HttpStatus.BAD_GATEWAY,
      message,
      userMessage,
    });
  }

  static internal(
    message = 'Unexpected internal error.',
    userMessage = 'Algo saiu do esperado no servidor. Tente novamente em instantes.',
  ): AppException {
    return new AppException({
      code: ErrorCode.InternalError,
      status: HttpStatus.INTERNAL_SERVER_ERROR,
      message,
      userMessage,
    });
  }
}
