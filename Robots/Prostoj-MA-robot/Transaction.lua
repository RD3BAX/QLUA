
Transaction = {};

-- Совершает СДЕЛКУ указанного типа (Type) ["BUY", или "SELL"] по рыночной(текущей) цене размером в 1 лот,
--- возвращает цену открытой сделки, либо FALSE, если невозможно открыть сделку
function Transaction.Trade(Type)
   --Получает ID транзакции
   trans_id = trans_id + 1;

   local Price = 0;
   local Operation = '';
   --Устанавливает цену и операцию, в зависимости от типа сделки и от класса инструмента
   if Type == 'BUY' then
      if CLASS_CODE ~= 'QJSIM' and CLASS_CODE ~= 'TQBREMU' then 
		Price = getParamEx(CLASS_CODE, SEC_CODE, 'offer').param_value + 10*SEC_PRICE_STEP;end; -- по цене, завышенной на 10 мин. шагов цены
      Operation = 'B';
   else
      if CLASS_CODE ~= 'QJSIM' and CLASS_CODE ~= 'TQBREMU' then 
		Price = getParamEx(CLASS_CODE, SEC_CODE, 'bid').param_value - 10*SEC_PRICE_STEP;end; -- по цене, заниженной на 10 мин. шагов цены
      Operation = 'S';
   end;
   
   -- Заполняет структуру для отправки транзакции
   local Transaction={
      ['TRANS_ID']   = tostring(trans_id),
      ['ACTION']     = 'NEW_ORDER',
      ['CLASSCODE']  = CLASS_CODE,
      ['SECCODE']    = SEC_CODE,
      ['OPERATION']  = Operation, -- операция ("B" - buy, или "S" - sell)
      ['TYPE']       = 'M', -- по рынку (MARKET)
      ['QUANTITY']   = '1', -- количество
      ['ACCOUNT']    = ACCOUNT,
--	  ['CLIENT_CODE'] = '1099U',
      ['PRICE']      = tostring(Price),
      ['COMMENT']    = 'Простой MA-робот'
   }
   -- Отправляет транзакцию
   sendTransaction(Transaction);
   -- Ждет, пока получит статус текущей транзакции (переменные "trans_Status" и "trans_result_msg" заполняются в функции OnTransReply())
   while Run and trans_Status == nil do sleep(1); end;
   -- Запоминает значение
   local Status = trans_Status;
   -- Очищает глобальную переменную
   trans_Status = nil;
   -- Если транзакция не выполнена по какой-то причине
   if Status ~= 3 then
      -- Если данный инструмент запрещен для операции шорт
      if Status == 6 then
         -- Выводит сообщение
         message('Простой MA-робот: Данный инструмент запрещен для операции шорт!');
         SEC_NO_SHORT = true;
      else
         -- Выводит сообщение с ошибкой
         message('Простой MA-робот: Транзакция не прошла!\nОШИБКА: '..trans_result_msg);
      end;
      -- Возвращает FALSE
      return false;
   else --Транзакция отправлена
      local OrderNum = nil;
      --ЖДЕТ пока ЗАЯВКА на ОТКРЫТИЕ сделки будет ИСПОЛНЕНА полностью
      --Запоминает время начала в секундах
      local BeginTime = os.time();
      while Run and OrderNum == nil do
         --Перебирает ТАБЛИЦУ ЗАЯВОК
         for i=0,getNumberOf('orders')-1 do
            local order = getItem('orders', i);
            --Если заявка по отправленной транзакции ИСПОЛНЕНА ПОЛНОСТЬЮ
            if order.trans_id == trans_id and order.balance == 0 then
               --Запоминает номер заявки
               OrderNum  = order.order_num;
               --Прерывает цикл FOR
               break;
            end;
         end;
         --Если прошло 10 секунд, а заявка не исполнена, значит произошла ошибка
         if os.time() - BeginTime > 9 then
            -- Выводит сообщение с ошибкой
            message('Простой MA-робот: Прошло 10 секунд, а заявка не исполнена, значит произошла ошибка');
            -- Возвращает FALSE
            return false;
         end;
         sleep(10); -- Пауза 10 мс, чтобы не перегружать процессор компьютера
      end;

      --ЖДЕТ пока СДЕЛКА ОТКРЫТИЯ позиции будет СОВЕРШЕНА
      --Запоминает время начала в секундах
      BeginTime = os.time();
      while Run do
         --Перебирает ТАБЛИЦУ СДЕЛОК
         for i=0,getNumberOf('trades')-1 do
            local trade = getItem('trades', i);
            --Если сделка по текущей заявке
            if trade.order_num == OrderNum then
               --Возвращает фАКТИЧЕСКУЮ ЦЕНУ открытой сделки
               return trade.price;
            end;
         end;
         --Если прошло 10 секунд, а сделка не совершена, значит на демо-счете произошла ошибка
         if os.time() - BeginTime > 9 then
            -- Выводит сообщение с ошибкой
            message('Простой MA-робот: Прошло 10 секунд, а сделка не совершена, значит на демо-счете произошла ошибка');
            -- Возвращает FALSE
            return false;
         end;
         sleep(10); -- Пауза 10 мс, чтобы не перегружать процессор компьютера
      end;
   end;
end;

function Transaction.nameFunction()
    -- Действия
end
return Transaction;