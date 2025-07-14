import GetPut::*;
import FIFOF::*;
import CommonIfc::*;

module mkManchesterDecoder(FrameBitProcessor);
    Reg#(Maybe#(Bit#(1))) prevSample <- mkReg(Invalid);
    Reg#(Bit#(4)) sampleCount <- mkReg(0);  // 4 bits para contar até pelo menos 9
    FIFOF#(Maybe#(Bit#(1))) outFifo <- mkFIFOF;

    interface Put in;
        method Action put(Maybe#(Bit#(1)) inBit);
            if (inBit matches tagged Valid .b) begin
                if (prevSample matches tagged Valid .prevB) begin
                    if (b != prevB) begin
                        // transição detectada → ressincroniza
                        if (sampleCount == 4) begin
                            // transição no meio do símbolo → decodifica bit
                            outFifo.enq(Valid(b));
                        end
                        // realinha fase
                        sampleCount <= 1;
                    end else begin
                        // sem transição → continua contando
                        sampleCount <= sampleCount + 1;
                    end
                end else begin
                    // primeira amostra válida → inicia contagem
                    sampleCount <= 1;
                end
                prevSample <= inBit;
            end else begin
                // fim de quadro → repassa Invalid e reseta
                prevSample  <= Invalid;
                sampleCount <= 0;
                outFifo.enq(Invalid);
            end
        endmethod
    endinterface

    interface out = toGet(outFifo);
endmodule

